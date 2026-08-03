import { Module } from "@nestjs/common";
import { CsrfService } from "./csrf.service.js";
import { SecurityController } from "./security.controller.js";

@Module({
  controllers: [SecurityController],
  providers: [CsrfService],
  exports: [CsrfService],
})
export class SecurityModule {}
