import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto {
    id: number;
    fullname: string;
    dob: string;
    email: string;
    contact: string;
    gender: string;
    city: string;
}
