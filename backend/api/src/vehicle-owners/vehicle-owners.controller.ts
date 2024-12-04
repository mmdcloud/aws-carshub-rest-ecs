import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { VehicleOwnersService } from './vehicle-owners.service';
import { CreateVehicleOwnerDto } from './dto/create-vehicle-owner.dto';
import { UpdateVehicleOwnerDto } from './dto/update-vehicle-owner.dto';
import { AuthGuard } from 'src/auth.guard';

@Controller('vehicle-owners')
export class VehicleOwnersController {
  constructor(private readonly vehicleOwnersService: VehicleOwnersService) {}

  @UseGuards(AuthGuard)
  @Post()
  create(@Body() createVehicleOwnerDto: CreateVehicleOwnerDto) {
    return this.vehicleOwnersService.create(createVehicleOwnerDto);
  }

  @UseGuards(AuthGuard)
  @Get()
  findAll() {
    return this.vehicleOwnersService.findAll();
  }

  @UseGuards(AuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.vehicleOwnersService.findOne(+id);
  }

  @UseGuards(AuthGuard)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateVehicleOwnerDto: UpdateVehicleOwnerDto) {
    return this.vehicleOwnersService.update(+id, updateVehicleOwnerDto);
  }

  @UseGuards(AuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.vehicleOwnersService.remove(+id);
  }
}
