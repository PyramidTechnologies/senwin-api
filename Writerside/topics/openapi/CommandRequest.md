#  CommandRequest

Commands are sent to the kiosk to trigger an action.

**Out of Service** - displays an out of service screen that prevents redeeming until cancelled, expired, or a technician
clears the screen at the kiosk

**Reset Dispenser** - resets/initializes the dispenser and attempts to clear any jams. Kiosk is marked out of service
while dispenser is initializing

**Restart** - restarts the kiosk via the OS

<api-schema openapi-path="../../openapi.yaml" name="CommandRequest"></api-schema>