# Webhooks

## Security

Each request sent to your webhook destination will include the `Sentry-Signature` header.
You can check this signature by calculating the HMAC-SHA256 with the private key created
when you added the destination.

## Event Structure

```JSON
{
  "correlationId": "",
  "deviceId": "",
  "type": "",
  "version": 1,
  "data": {
    ...
  }
}
```

<api-schema openapi-path="../../openapi.yaml" name="Event"></api-schema>

