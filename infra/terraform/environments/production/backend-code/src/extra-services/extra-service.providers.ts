import { ExtraService } from './entities/extra-service.entity';

export const extraServicesProviders = [
    {
        provide: 'EXTRA_SERVICES_REPOSITORY',
        useValue: ExtraService,
    },
];
