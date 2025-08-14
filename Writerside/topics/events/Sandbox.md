# Sandbox

The sandbox page can be used to test your event destinations.

## 1. Create a new device

Using the dashboard:

*W.I.P.*

Using the API:

```Console
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -d '{"name": "test"}' \
  "ryken.senwin.dev/sandbox/devices"
```

Example response:
```json
{
  "deviceId": "SB-01234567",
  "pairingCode": "01234567",
  "expiresAt": "2025-08-14T09:12:28Z"
}
```


## 2. Pair the device

Once a device has been created, it needs to be paired to your account before you can receive events from it.
You may pair it using the API by selecting `Generate Pairing Code` or it can be paired for you by selecting `Pair Device`.

```Console
curl -X POST \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: <YOUR_API_KEY>" \
    -d '{"pairingCode": "<PAIRING_CODE>"}' \
    "ryken.senwin.dev/pair"
```

## 3. Generate an event

To generate random event data of a specific type:

*Type refers to the schema name of the event, i.e., "Redemption", "Fill", etc.*

```Console
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -d '{"deviceId": "<SANDBOX_DEVICE_ID>", "type": "Redemption"}' \
  "ryken.senwin.dev/sandbox/events"
```

Or, specify the data to send:

```Console
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -d '{"deviceId": "<SANDBOX_DEVICE_ID>", "type": "DeviceShadow", "data": { "isOutOfService": false } }' \
  "ryken.senwin.dev/sandbox/events"
```