import { Brand } from './entities/brand.entity';

export const brandsProviders = [
    {
        provide: 'BRANDS_REPOSITORY',
        useValue: Brand,
    },
];