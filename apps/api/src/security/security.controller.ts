import { Controller, Get, Res, Version } from "@nestjs/common";
import { ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import type { Response } from "express";
import { CsrfService } from "./csrf.service.js";

@ApiTags("security")
@Controller("security")
export class SecurityController {
  constructor(private readonly csrfService: CsrfService) {}

  @Get("csrf-token")
  @Version("1")
  @ApiOperation({ summary: "Issue a CSRF token for cookie-authenticated mutations" })
  @ApiOkResponse({
    schema: {
      type: "object",
      required: ["csrfToken"],
      properties: { csrfToken: { type: "string" } },
    },
  })
  getCsrfToken(@Res({ passthrough: true }) response: Response): { csrfToken: string } {
    return { csrfToken: this.csrfService.issue(response) };
  }
}
