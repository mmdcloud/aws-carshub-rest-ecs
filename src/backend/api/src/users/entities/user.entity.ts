import { Table, Column, Model } from 'sequelize-typescript';

@Table
export class User extends Model {
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

    @Column
    password: string;
}