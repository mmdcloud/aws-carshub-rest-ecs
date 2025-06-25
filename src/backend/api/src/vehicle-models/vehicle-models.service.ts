import { Inject, Injectable } from '@nestjs/common';
import { UpdateVehicleModelDto } from './dto/update-vehicle-model.dto';
import { VehicleModel } from './entities/vehicle-model.entity';

@Injectable()
export class VehicleModelsService {
  constructor(
    @Inject('VEHICLE_MODELS_REPOSITORY')
    private vehicleModelsRepository: typeof VehicleModel
  ) { }
  async create(createVehicleModelDto) {
    const vehicleModel = new VehicleModel(createVehicleModelDto);
    return await vehicleModel.save();
  }

  async findAll(): Promise<VehicleModel[]> {
    return this.vehicleModelsRepository.findAll<VehicleModel>({
      include: "brand"
    });
  }

  async findOne(id: number): Promise<VehicleModel> {
    return this.vehicleModelsRepository.findByPk<VehicleModel>(id,{
      include: "brand"
    });
  }

  async update(id: number, updateVehicleModelDto: UpdateVehicleModelDto): Promise<[number, VehicleModel[]]> {
    const [affectedCount, affectedRows] = await this.vehicleModelsRepository.update(updateVehicleModelDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as VehicleModel[]];
  }

  async remove(id: number): Promise<number> {
    return this.vehicleModelsRepository.destroy({ where: { id: id } });
  }
}
