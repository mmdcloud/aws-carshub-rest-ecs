import { Inject, Injectable } from '@nestjs/common';
import { UpdateVehicleOwnerDto } from './dto/update-vehicle-owner.dto';
import { VehicleOwner } from './entities/vehicle-owner.entity';

@Injectable()
export class VehicleOwnersService {
  constructor(
    @Inject('VEHICLE_OWNERS_REPOSITORY')
    private vehicleOwnersRepository: typeof VehicleOwner
  ) { }
  async create(createVehicleOwnerDto): Promise<VehicleOwner> {
    const owner = new VehicleOwner(createVehicleOwnerDto);
    return await owner.save();
  }

  async findAll(): Promise<VehicleOwner[]> {
    return this.vehicleOwnersRepository.findAll<VehicleOwner>();
  }

  async findOne(id: number): Promise<VehicleOwner> {
    return this.vehicleOwnersRepository.findByPk<VehicleOwner>(id);
  }

  async update(id: number, updateVehicleOwnerDto: UpdateVehicleOwnerDto): Promise<[number, VehicleOwner[]]> {
    const [affectedCount, affectedRows] = await this.vehicleOwnersRepository.update(updateVehicleOwnerDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as VehicleOwner[]];
  }

  async remove(id: number): Promise<number> {
    return this.vehicleOwnersRepository.destroy({ where: { id: id } });
  }
}
