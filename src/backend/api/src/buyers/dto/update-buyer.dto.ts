import { PartialType } from '@nestjs/mapped-types';
import { CreateBuyerDto } from './create-buyer.dto';

export class UpdateBuyerDto extends PartialType(CreateBuyerDto) {
    id: number;
    fullname: string;
    dob: string;
    email: string;
    contact: string;
    gender: string;
    city: string;
}
