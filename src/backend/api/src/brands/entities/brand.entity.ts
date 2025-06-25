import { Table, Column, Model } from 'sequelize-typescript';

@Table
export class Brand extends Model {
    @Column
    name: string;

    @Column
    countryOfOrigin: string;
}
