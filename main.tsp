import "@typespec/http";

using Http;
@service(#{ title: "SenWin" })
namespace SenWin;

enum RedemptionStatus {
  redeemed: "redeemed",
  duplicate: "duplicate",
  expired: "expired",
}

enum DeviceStatus {
  okay: "okay",
  low: "low",
  empty: "empty",
}

enum DispenseError {
  none: "none",
  outOfBills: "outOfBills",
  jammed: "jammed",
  error: "error"
}

model Cassette {
  denomination: int16;
  count: int16;
}

model CassetteFill {
  ...Cassette;
  filled: int16;
  dispensed: int16;
  rejected: int16;
}

model CassetteDispense {
  ...Cassette;
  dispensed: int16;
  rejected: int16;
}

model Redemption {
  id: int64;
  device_id: int64;
  amount: int32;
  time_in: utcDateTime;
  redeemed_at: utcDateTime;
  created_at: utcDateTime;
  hash: string;
  printer_serial: string;
  status: RedemptionStatus;
}

model LoginEvent {
  id: int64;
  device_id: int64;
  failed_attempts: int8;
  attempted_at: utcDateTime;
  user: string;
  logged_in: boolean;
}

model FillEvent {
  id: int64;
  device_id: int64;
  amount: int32;
  time_in: utcDateTime;
  printer_serial: string;
  created_at: utcDateTime;
  cassettes: CassetteFill[];
}

model DispenseEvent {
  id: int64;
  device_id: int64;
  timestamp: utcDateTime;
  cassettes: CassetteDispense[];
  error: DispenseError;
  error_message?: string;
}

model PeriodReport {
  device_id: int64;
  start: utcDateTime;
  end: utcDateTime;
  totalRedeemed: int32;
  totalDue: int32;
}

model Device {
  id: int64;
  fleet_id: int64;
  serial_number: string;
  status: DeviceStatus;
  last_seen: utcDateTime;
  app_version: string;
  status_message?: string;
  nickname?: string;
}

enum CommandType {
  outOfService: "outOfService",
  restart: "restart",
  resetDispenser: "resetDispenser"
}

model CommandRequest {
  command: CommandType;
  scheduleFor?: utcDateTime;
  expireAfter?: utcDateTime;
}

model CommandResponse {
  command_id: int64;
  device_id: int64;
}

enum CommandStatus {
  pending: "pending",
  success: "success",
  failed: "failed",
  canceled: "canceled"
}

model Command {
  command_id: int64;
  device_id: int64;
  command: CommandType;
  status: CommandStatus;
  sent_at: utcDateTime;
  scheduled_for?: utcDateTime;
  expire_after?: utcDateTime;
}

model PairingRequest {
  pairing_code: string;
}

model Fleet {
  id: int64;
  name: string;
}

@error
model Error {
  message: string;
}

model BadRequestError {
  @statusCode statusCode: 400;
  @body error: Error;
}

model UnauthorizedError {
  @statusCode statusCode: 401;
  @body error: Error;
}

model ForbiddenError {
  @statusCode statusCode: 403;
  @body error: Error;
}

model NotFoundError {
  @statusCode statusCode: 404;
  @body error: Error;
}

model InternalServerError {
  @statusCode statusCode: 500;
  @body error: Error;
}

alias CommonErrors =  UnauthorizedError | NotFoundError | InternalServerError;
alias CommonRequestErrors = BadRequestError | CommonErrors;

model DateRangeParams {
  @query startDate?: utcDateTime;
  @query endDate?: utcDateTime;
}

model PagingParams {
  @query @continuationToken cursor?: string;
}

model PagingResponse<T> {
  @statusCode statusCode: 200;
  @body body: {
    @pageItems items: T[];
    @continuationToken nextCursor?: string;
  };
}

@route("/v1/fleets")
namespace Fleets {
  @get 
  op getFleets(): {
    @statusCode statusCode: 200;
    @body fleets: Fleet[];
  } | NotFoundError | UnauthorizedError;

  @post
  op createFleet(@body name: string): {
    @statusCode statusCode: 201;
    @body fleet: Fleet;
  } | BadRequestError | UnauthorizedError;

  @get
  op getFleet(@path fleetId: int64): {
    @statusCode statusCode: 200;
    @body fleet: Fleet;
  } | NotFoundError | UnauthorizedError;

  @put
  op updateFleet(@path fleetId: int64, @body name: string): {
    @statusCode statusCode: 200;
    @body Fleet: Fleet;
  } | BadRequestError | UnauthorizedError | NotFoundError;

  @delete
  op deleteFleet(@path fleetId: int64): {
    @statusCode statusCode: 204;
  } | NotFoundError | UnauthorizedError;

  @route("/{fleetId}/devices")
  namespace Devices {
    @get
    op getDevices(@path fleetId: int64, ...PagingParams): PagingResponse<Device> | CommonRequestErrors;

    @post
    op pairDevice(@path fleetId: int64, @body body: PairingRequest): {
      @statusCode statusCode: 201;
      @body device: Device;
    } | {
      @statusCode statusCode: 400;
      @body error: Error;
    } | CommonErrors;
  }
  
  @route("/{fleetId}/redemptions")
  namespace Redemptions {
    @get
    op getRedemptions(@path fleetId: int64, ...DateRangeParams, ...PagingParams): 
      PagingResponse<Redemption> | CommonRequestErrors;
  }

  @route("/{fleetId}/fills")
  namespace Fills {
    @get
    op getFills(@path fleetId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<FillEvent> | CommonRequestErrors ;
  }

  @route("/{fleetId}/periods")
  namespace Periods {
    @get
    op getPeriods(@path fleetId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<PeriodReport> | CommonRequestErrors;
  }
}

@route("/v1/devices/{deviceId}")
namespace Devices {
  @get
  op getDevice(@path deviceId: int64): {
    @statusCode statusCode: 200;
    @body device: Device;
  } | CommonErrors;

  @put
  op updateDeviceName(@path deviceId: int64, @body nickname: string): {
    @statusCode statusCode: 200;
  } | CommonRequestErrors;

  @delete
  op removeDevice(@path deviceId: int64): {
    @statusCode statusCode: 204;
  } | CommonErrors;

  namespace Commands {
    @post
    op sendCommand(@path deviceId: int64, @body command: CommandRequest): {
      @statusCode statusCode: 201;
      @body command: CommandResponse;
    } | CommonRequestErrors;

    @get
    op getCommandStatus(@path deviceId: int64, @path commandId: string): {
      @statusCode statusCode: 200;
      @body command: Command;
    } | CommonRequestErrors;

    @delete
    op cancelCommand(@path deviceId: int64, @path commandId: string): {
      @statusCode statusCode: 204;
    } | CommonRequestErrors;
  }

  @route("/redemptions")
  namespace Redemptions {
    @get
    op getRedemptions(@path deviceId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<Redemption> | CommonRequestErrors;
  }

  @route("/fills")
  namespace Fills {
    @get
    op getFills(@path deviceId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<FillEvent> | CommonRequestErrors;
  }

  @route("/logins")
  namespace Logins {
    @get
    op getLogins(@path deviceId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<LoginEvent> | CommonRequestErrors;
  }

  @route("/periods")
  namespace Periods {
    @get
    op getPeriods(@path deviceId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<PeriodReport> | CommonRequestErrors;
  }

  @route("/dispenses")
  namespace Dispenses {
    @get
    op getDispenses(@path deviceId: int64, ...DateRangeParams, ...PagingParams):
      PagingResponse<DispenseEvent> | CommonRequestErrors;
  }
}


