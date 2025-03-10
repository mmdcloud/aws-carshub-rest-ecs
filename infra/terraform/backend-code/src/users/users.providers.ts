import { User } from './entities/user.entity';

export const usersProviders = [
    {
        provide: 'USERS_REPOSITORY',
        useValue: User,
    },
];