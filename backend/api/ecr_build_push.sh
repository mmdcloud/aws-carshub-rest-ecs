#!/bin/bash
mkdir code
cp -r ../../backend/api/* code/
cd code

cat > .env << EOL
CORS_URL=$6
EOL

cat > src/database.providers.ts << EOL
import { Sequelize } from 'sequelize-typescript';
import { User } from './users/entities/user.entity';
import { Brand } from './brands/entities/brand.entity';
import { Buyer } from './buyers/entities/buyer.entity';
import { VehicleModel } from './vehicle-models/entities/vehicle-model.entity';
import { VehicleOwner } from './vehicle-owners/entities/vehicle-owner.entity';
import { ExtraService } from './extra-services/entities/extra-service.entity';
import { Order } from './orders/entities/order.entity';
import { InventoryImage } from './inventory/entities/inventory-image.entity';
import { Inventory } from './inventory/entities/inventory.entity';

export const databaseProviders = [
     {
            provide: 'SEQUELIZE',
            useFactory: async () => {
                const sequelize = new Sequelize({
                    dialect: 'mysql',
                    host: '$5',
                    port: 3306,
                    username: '$3',
                    password: '$4',
                    database: 'carshub',
                });
                sequelize.addModels([
                    User, Brand, Buyer, VehicleModel, VehicleOwner, ExtraService,
                    Order, Inventory, InventoryImage
                ]);
                await sequelize.sync({
                    force: false
                });
                return sequelize;
            },
      },
];
EOL
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region $2 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$2.amazonaws.com
#docker buildx build --tag $1 --file ./Dockerfile . 
docker build -t $1 .
docker tag $1:latest $ACCOUNT_ID.dkr.ecr.$2.amazonaws.com/$1:latest
docker push $ACCOUNT_ID.dkr.ecr.$2.amazonaws.com/$1:latest
