import { Table, Column, Model, ForeignKey, BelongsTo } from 'sequelize-typescript';
import { Brand } from 'src/brands/entities/brand.entity';

@Table
export class VehicleModel extends Model {
    @Column
    name: string;    

    @ForeignKey(() => Brand)
    @Column
    brandId: number;

    @BelongsTo(() => Brand)
    brand: Brand;
}