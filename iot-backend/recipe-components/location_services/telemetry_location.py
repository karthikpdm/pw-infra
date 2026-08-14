import json
import logging
import boto3
import polyline
from datetime import datetime, timezone
from awsiot import mqtt_connection_builder
from awscrt import mqtt
import threading
import time

# Enable logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# AWS IoT Core settings
AWS_IOT_ENDPOINT = "a1o4c7mi1myu75-ats.iot.us-east-1.amazonaws.com"
CLIENT_ID = "iotconsole-c0bc6d43-6594-43b5-b99e-3eca45c53435"


AWS_IOT_PORT = 8883
AWS_IOT_TOPIC_PUBLISH = "greengrass/generateTelemetry"

CA_CERT = "/greengrass/v2/rootCA.pem"
CLIENT_CERT = "/greengrass/v2/thingCert.crt"
PRIVATE_KEY = "/greengrass/v2/privKey.key"


# AWS Location Service settings
ROUTE_CALCULATOR_NAME = "telemetryRouteCalculator"
AWS_REGION = "us-east-1"
COGNITO_IDENTITY_POOL_ID = "us-east-1:8bf49451-a362-4bb9-a8bf-cc7211e06fc5"

# Vehicle settings
VIN = "1HGCM82633A004352"
POINTS_PER_SEGMENT = 5

def get_credentials():
    try:
        logger.info("Getting credentials from Cognito Identity Pool")
        cognito_identity = boto3.client('cognito-identity', region_name=AWS_REGION)

        identity_response = cognito_identity.get_id(
            IdentityPoolId=COGNITO_IDENTITY_POOL_ID
        )

        credentials_response = cognito_identity.get_credentials_for_identity(
            IdentityId=identity_response['IdentityId']
        )

        credentials = {
            'aws_access_key_id': credentials_response['Credentials']['AccessKeyId'],
            'aws_secret_access_key': credentials_response['Credentials']['SecretKey'],
            'aws_session_token': credentials_response['Credentials']['SessionToken']
        }

        logger.info("Successfully obtained credentials from Cognito")
        return credentials

    except Exception as e:
        logger.error(f"Error getting Cognito credentials: {e}")
        raise

def fetch_route(start_coords, end_coords):
    """Fetch route from AWS Location Service"""
    try:
        credentials = get_credentials()

        logger.info(f"Initializing AWS Location Service client for region {AWS_REGION}")

        location_client = boto3.client(
            'location',
            region_name=AWS_REGION,
            aws_access_key_id=credentials['aws_access_key_id'],
            aws_secret_access_key=credentials['aws_secret_access_key'],
            aws_session_token=credentials['aws_session_token']
        )

        logger.info(f"Calculating route from {start_coords} to {end_coords}")
        response = location_client.calculate_route(
            CalculatorName=ROUTE_CALCULATOR_NAME,
            DeparturePosition=[start_coords[1], start_coords[0]],  # [longitude, latitude]
            DestinationPosition=[end_coords[1], end_coords[0]],   
            IncludeLegGeometry=True,
            DepartNow=True,
            TravelMode='Truck',
            TruckModeOptions={
                'AvoidFerries': True,
                'AvoidTolls': False
            }
        )

        logger.info("Route calculation successful")
        return response
    except Exception as e:
        logger.error(f"Error fetching route from AWS Location Service: {e}")
        if hasattr(e, 'response'):
            logger.error(f"Error Response: {e.response}")
        return None

def decode_route(route_response):
    """Extract waypoints from AWS Location Service response"""
    if not route_response or 'Legs' not in route_response:
        logger.error("Invalid route response format")
        return None

    try:
        # Extract the geometry from the first leg
        geometry = route_response['Legs'][0]['Geometry']['LineString']

        # AWS Location Service returns points in [longitude, latitude] format
        # Convert to [latitude, longitude] format for consistency
        waypoints = [[point[1], point[0]] for point in geometry]

        logger.info(f"Successfully decoded {len(waypoints)} waypoints from route")
        return waypoints
    except Exception as e:
        logger.error(f"Error decoding route geometry: {e}")
        return None

def calculate_heading(start_point, end_point):
    """Calculate heading between two points"""
    from math import atan2, degrees
    lat1, lon1 = start_point
    lat2, lon2 = end_point
    delta_lon = lon2 - lon1
    delta_lat = lat2 - lat1
    heading = degrees(atan2(delta_lon, delta_lat))
    return round((heading + 360) % 360, 2)

def generate_telemetry_data(current_point, next_point, index, total_points):
    """Generate telemetry data for a given point"""
    latitude, longitude = current_point
    heading = calculate_heading(current_point, next_point)
    base_speed = 35.0
    speed = base_speed * 0.7 if index % POINTS_PER_SEGMENT < 2 or index % POINTS_PER_SEGMENT > POINTS_PER_SEGMENT - 2 else base_speed

    logger.debug(f"Generating telemetry data for point {index + 1}/{total_points}")
    return {
        "VIN": VIN,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "location": {
            "lat": round(latitude, 8),
            "long": round(longitude, 8)
        },
        "accuracy": {"Horizontal": 3.0},
        "heading": heading,
        "speed": speed,
        "batteryVoltage": 445.63,
        "batterySOC": 98.0
    }

def start_processing(waypoints, mqtt_connection):
    total_points = len(waypoints)
    if total_points > 0:
        logger.info("Starting waypoint processing")
        process_waypoint(0, waypoints, total_points, mqtt_connection)    

def process_waypoint(i, waypoints, total_points, mqtt_connection):
    logger.debug(f"Processing waypoint {i + 1}/{total_points}")

    current_point = waypoints[i]
    next_point = waypoints[i + 1]

    telemetry_data = generate_telemetry_data(current_point, next_point, i, total_points)
    message = json.dumps(telemetry_data)

    logger.info(f"Publishing telemetry message {i + 1}/{total_points}")
    logger.debug(f"Message content: {message}")

    mqtt_connection.publish(
        topic=AWS_IOT_TOPIC_PUBLISH,
        payload=message,
        qos=mqtt.QoS.AT_LEAST_ONCE
    )
    logger.info(f"Message {i + 1} published successfully")

    if i + 1 < total_points - 1:  
        timer = threading.Timer(1.5, process_waypoint, args=(i + 1, waypoints, total_points, mqtt_connection))
        timer.start()

def on_connection_interrupted(connection, error, **kwargs):
    logger.error(f"Connection interrupted. error: {error}")

def on_connection_resumed(connection, return_code, session_present, **kwargs):
    logger.info(f"Connection resumed. return_code: {return_code}, session_present: {session_present}")

def main():
    global mqtt_connection

    # Verify Cognito Identity Pool ID is set
    if COGNITO_IDENTITY_POOL_ID.endswith("YOUR_IDENTITY_POOL_ID"):
        logger.error("Please set your actual Cognito Identity Pool ID in the COGNITO_IDENTITY_POOL_ID variable")
        return

    logger.info("Initializing MQTT connection")
    mqtt_connection = mqtt_connection_builder.mtls_from_path(
        endpoint=AWS_IOT_ENDPOINT,
        port=AWS_IOT_PORT,
        cert_filepath=CLIENT_CERT,
        pri_key_filepath=PRIVATE_KEY,
        ca_filepath=CA_CERT,
        client_id=CLIENT_ID,
        clean_session=False,
        keep_alive_secs=30,
        on_connection_interrupted=on_connection_interrupted,
        on_connection_resumed=on_connection_resumed,
    )

    logger.info("Connecting to AWS IoT Core...")
    connect_future = mqtt_connection.connect()
    connect_future.result()
    logger.info("Connected successfully to AWS IoT Core")

    start_coords = [42.259734, -83.314518]
    end_coords = [42.13714093848415, -83.39600661551916]

    route_response = fetch_route(start_coords, end_coords)
    if not route_response:
        logger.error("Failed to fetch route. Exiting.")
        return

    waypoints = decode_route(route_response)
    if not waypoints:
        logger.error("Failed to decode route. Exiting.")
        return

    logger.info(f"Successfully retrieved route with {len(waypoints)} points")
    start_processing(waypoints, mqtt_connection)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
    finally:
        logger.info("Disconnecting from AWS IoT Core...")
        disconnect_future = mqtt_connection.disconnect()
        disconnect_future.result()
        logger.info("Disconnected successfully")

if __name__ == "__main__":
    main()