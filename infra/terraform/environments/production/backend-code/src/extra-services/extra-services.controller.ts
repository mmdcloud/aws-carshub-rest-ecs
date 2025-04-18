import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { ExtraServicesService } from './extra-services.service';
import { CreateExtraServiceDto } from './dto/create-extra-service.dto';
import { UpdateExtraServiceDto } from './dto/update-extra-service.dto';
import { AuthGuard } from 'src/auth.guard';

@Controller('extra-services')
export class ExtraServicesController {
  constructor(private readonly extraServicesService: ExtraServicesService) {}

  @UseGuards(AuthGuard)
  @Post()
  create(@Body() createExtraServiceDto: CreateExtraServiceDto) {
    return this.extraServicesService.create(createExtraServiceDto);
  }

  @UseGuards(AuthGuard)
  @Get()
  findAll() {
    return this.extraServicesService.findAll();
  }

  @UseGuards(AuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.extraServicesService.findOne(+id);
  }

  @UseGuards(AuthGuard)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateExtraServiceDto: UpdateExtraServiceDto) {
    return this.extraServicesService.update(+id, updateExtraServiceDto);
  }

  @UseGuards(AuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.extraServicesService.remove(+id);
  }
}
