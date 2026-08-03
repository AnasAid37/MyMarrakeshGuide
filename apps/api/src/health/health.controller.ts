import { Controller, Get, Res, Version } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiServiceUnavailableResponse, ApiTags } from "@nestjs/swagger";
import type { HealthResponse } from "@mmg/contracts";
import type { Response } from "express";
import { HealthService } from "./health.service.js";

@ApiTags("health")
@Controller("health")
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get("live")
  @Version("1")
  @ApiOperation({ summary: "Process liveness check" })
  @ApiOkResponse({ description: "The API process is running." })
  liveness(): HealthResponse {
    return this.healthService.liveness();
  }

  @Get("ready")
  @Version("1")
  @ApiOperation({ summary: "Dependency readiness check" })
  @ApiOkResponse({ description: "All required dependencies are available." })
  @ApiServiceUnavailableResponse({ description: "One or more required dependencies are unavailable." })
  async readiness(@Res({ passthrough: true }) response: Response): Promise<HealthResponse> {
    const health = await this.healthService.readiness();
    response.status(health.status === "ok" ? 200 : 503);
    response.setHeader("Cache-Control", "no-store");
    return health;
  }
}
