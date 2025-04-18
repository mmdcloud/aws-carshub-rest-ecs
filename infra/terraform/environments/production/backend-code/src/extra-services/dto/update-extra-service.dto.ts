import { PartialType } from '@nestjs/mapped-types';
import { CreateExtraServiceDto } from './create-extra-service.dto';

export class UpdateExtraServiceDto extends PartialType(CreateExtraServiceDto) {
    id: number;
    title: string;
    discount: string;
    price: string;
}
