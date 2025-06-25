import { Table, Column, Model } from 'sequelize-typescript';

@Table
export class Buyer extends Model {
    @Column
    fullname: string;

    @Column
    city: string;

    @Column
    dob: string;

    @Column
    gender: string;

    @Column
    contact: string;

    @Column
    email: string;
}