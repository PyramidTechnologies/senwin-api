#  /v1/devices/{deviceId}/periods GET

Lists the period reports for the device. Periods are an arbitrary time range generated from the operator. An operator may
choose to create a period when: a shift ends, a collection is made, a fill is done, etc. Each period starts when the previous
period ends.

<api-endpoint openapi-path="../../../tsp-output/schema/openapi.yaml" method="GET" endpoint="/v1/devices/{deviceId}/periods"></api-endpoint>