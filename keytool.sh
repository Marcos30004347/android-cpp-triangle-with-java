mkdir -p build/keys
keytool -genkeypair -keystore build/keys/keystore.jks -alias androidkey \
      -validity 10000 -keyalg RSA -keysize 2048 \
      -storepass android -keypass android