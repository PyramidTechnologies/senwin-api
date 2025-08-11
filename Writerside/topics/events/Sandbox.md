# Sandbox

The sandbox page can be used to test your event destinations.

## 1. Create a new device

## 2. Pair the device

Once a device has been created, it needs to be paired to your account before you can receive events from it.
You may pair it using the API by selecting `Generate Pairing Code` or it can be paired for you by selecting `Pair Device`.

```Console
curl -X POST \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: <YOUR_API_KEY>" \
    -d '{"pairingCode": "<PAIRING_CODE>"}' \
    "<TODO_API_BASE_URL>/pair"
```

## 3. Send an event