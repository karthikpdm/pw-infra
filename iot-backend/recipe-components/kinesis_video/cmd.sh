sudo apt-get install cmake m4 git build-essential
git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp.git
mkdir -p amazon-kinesis-video-streams-producer-sdk-cpp/build
cd amazon-kinesis-video-streams-producer-sdk-cpp/build
sudo apt-get install libssl-dev libcurl4-openssl-dev liblog4cplus-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools
cmake .. -DBUILD_GSTREAMER_PLUGIN=ON
cd ..
export GST_PLUGIN_PATH=$(pwd)/build
export LD_LIBRARY_PATH=$(pwd)/open-source/local/lib
 
cd build
make

export CERT_PATH="/greengrass/v2/thingCert.crt"
export PRIVATE_KEY_PATH="/greengrass/v2/privKey.key"
export CA_CERT_PATH="/greengrass/v2/rootCA.pem"
export ROLE_ALIAS="kvs_rolealias"
export IOT_GET_CREDENTIAL_ENDPOINT="a136imfg2mklev-ats.iot.us-east-1.amazonaws.com"

sudo apt-get install python3-gi