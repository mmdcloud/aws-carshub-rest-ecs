import { VehicleModel } from './entities/vehicle-model.entity';

export const vehicleModelsProviders = [
    {
        provide: 'VEHICLE_MODELS_REPOSITORY',
        useValue: VehicleModel,
    },
];