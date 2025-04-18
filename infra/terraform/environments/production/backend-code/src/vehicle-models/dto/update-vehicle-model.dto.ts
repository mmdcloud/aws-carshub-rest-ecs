import { PartialType } from '@nestjs/mapped-types';
import { CreateVehicleModelDto } from './create-vehicle-model.dto';

export class UpdateVehicleModelDto extends PartialType(CreateVehicleModelDto) {
    id: number;
    name: string;
    brandId: number;
}
