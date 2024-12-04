import { VehicleOwner } from './entities/vehicle-owner.entity';

export const vehicleOwnersProviders = [
    {
        provide: 'VEHICLE_OWNERS_REPOSITORY',
        useValue: VehicleOwner,
    },
];