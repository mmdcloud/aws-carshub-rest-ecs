import { PartialType } from '@nestjs/mapped-types';
import { CreateVehicleOwnerDto } from './create-vehicle-owner.dto';

export class UpdateVehicleOwnerDto extends PartialType(CreateVehicleOwnerDto) {
    id: number;
    fullname: string;
    dob: string;
    email: string;
    contact: string;
    gender: string;
    city: string;
}
