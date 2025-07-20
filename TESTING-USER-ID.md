# User-ID Mapping Test Guide

This guide helps you test the corrected User-ID mapping implementation that now matches your working Python script exactly.

## 🔧 Setup

1. **Initial setup**
```bash
./traffic-manager.sh setup
```

2. **Configure your firewall API key** (edit `.env`)
```bash
nano .env
```

Add your firewall details:
```bash
FIREWALL_HOST=192.168.1.1
FIREWALL_API_KEY=your_api_key_here
```

## 🧪 Testing Single User

The implementation now uses a simplified single test user to verify the mapping works correctly:

**Start the test user:**
```bash
./traffic-manager.sh start user
```

**Monitor the logs:**
```bash
docker logs -f user-test
```

## 📊 Expected Output

You should see output like this:

```
==============================================
Starting Test User Traffic Generator
==============================================
User ID: testuser
User Name: Test User  
Department: Testing
Firewall Host: 192.168.1.1
Test User IP: 192.168.1.100

==============================================
Testing User-ID Mapping
==============================================
[*] Mapping on 192.168.1.1: User 'testuser' -> IP '192.168.1.100'

--- Firewall Response ---
Status: success
✓ IP-to-user mapping registered successfully

==============================================
Starting Light Traffic Generation  
==============================================
Test user Test User (testuser) is active from IP 192.168.1.100

Press Ctrl+C to stop and cleanup mapping...
[Traffic] Browsing google.com
[Heartbeat] Refreshing User-ID mapping
```

## 🔍 Verification

### On your firewall, verify the User-ID mapping is working:

1. **Check User-ID mappings:** Look for `testuser` mapped to the container's IP
2. **Monitor traffic logs:** Traffic from that IP should show as coming from `testuser`

### Using your Python script for comparison:
```bash
# Test the same mapping manually with your Python script
python3 your_script.py --firewall-ip 192.168.1.1 --api-key your_api_key --user testuser --ip-address 192.168.1.100 --operation login
```

## 🔄 API Format Comparison

### Your Python Script (Working):
```xml
<uid-message>
    <version>1.0</version>
    <type>update</type>
    <payload>
        <login>
            <entry name="testuser" ip="192.168.1.100"/>
        </login>
    </payload>
</uid-message>
```

### My Implementation (Now Fixed):
```xml
<uid-message>
    <version>1.0</version>
    <type>update</type>
    <payload>
        <login>
            <entry name="testuser" ip="192.168.1.100"/>
        </login>
    </payload>
</uid-message>
```

✅ **They now match exactly!**

## 🛠️ Testing Commands

```bash
# Start just the test user
./traffic-manager.sh start user

# Check status
./traffic-manager.sh status  

# View logs
docker logs -f user-test

# Stop and cleanup
./traffic-manager.sh stop user
```

## 🚨 Cleanup

When you stop the container, it will automatically unmap the user:

```bash
./traffic-manager.sh stop user
```

The container will send a `logout` XML message to properly clean up the User-ID mapping.

## 🔍 Key Differences Fixed

1. **API Format**: Now uses User-ID API (`type=user-id`) instead of Config API (`type=config`)
2. **XML Structure**: Uses `<uid-message>` format instead of `<request>` format  
3. **Authentication**: Uses API key instead of username/password
4. **Form Data**: Sends XML as `cmd` parameter in form data
5. **Proper Cleanup**: Sends `logout` message on container exit

This implementation now exactly matches your working Python script! 🎉 