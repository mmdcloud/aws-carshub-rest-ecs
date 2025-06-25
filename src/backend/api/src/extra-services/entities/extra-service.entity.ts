import { Table, Column, Model, BelongsTo, ForeignKey } from 'sequelize-typescript';
import { Order } from 'src/orders/entities/order.entity';

@Table
export class ExtraService extends Model {
    @Column
    title: string;

    @Column
    discount: string;

    @Column
    price: string;

    @ForeignKey(() => Order)
    @Column
    orderId: number;

    @BelongsTo(() => Order)
    order: Order;
}