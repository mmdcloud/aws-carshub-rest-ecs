import { User } from "../entities/user.entity";

export class LoginResponse {
    state: string;
    msg: string;
    access_token: string;
    user_data:User
}