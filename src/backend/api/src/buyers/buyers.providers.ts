import { Buyer } from './entities/buyer.entity';

export const buyersProviders = [
    {
        provide: 'BUYERS_REPOSITORY',
        useValue: Buyer,
    },
];