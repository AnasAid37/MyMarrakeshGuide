import { Controller, Get, Version } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("system")
@Controller()
export class SystemController {
  constructor(private readonly configService: ConfigService) {}

  @Get()
  @Version("1")
  @ApiOperation({ summary: "API service metadata" })
  @ApiOkResponse({
    schema: {
      type: "object",
      required: ["name", "version", "status"],
      properties: {
        name: { type: "string" },
        version: { type: "string" },
        status: { type: "string", enum: ["operational"] },
      },
    },
  })
  metadata(): { name: string; version: string; status: "operational" } {
    return {
      name: this.configService.getOrThrow<string>("APP_NAME"),
      version: this.configService.getOrThrow<string>("APP_VERSION"),
      status: "operational",
    };
  }
}
