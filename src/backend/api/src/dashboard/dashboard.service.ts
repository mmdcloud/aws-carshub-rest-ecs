import { Inject, Injectable } from '@nestjs/common';
import { CreateDashboardDto } from './dto/create-dashboard.dto';
import { UpdateDashboardDto } from './dto/update-dashboard.dto';
import { Buyer } from 'src/buyers/entities/buyer.entity';
import { Order } from 'src/orders/entities/order.entity';
import { Inventory } from 'src/inventory/entities/inventory.entity';
import { Brand } from 'src/brands/entities/brand.entity';
import { VehicleModel } from 'src/vehicle-models/entities/vehicle-model.entity';
import { VehicleOwner } from 'src/vehicle-owners/entities/vehicle-owner.entity';
import { GetDashboardData } from './dto/get-dashboard-data.dto';

@Injectable()
export class DashboardService {
  constructor(
    @Inject('BUYERS_REPOSITORY')
    private buyersRepository: typeof Buyer,
    @Inject('ORDERS_REPOSITORY')
    private ordersRepository: typeof Order,
    @Inject('INVENTORY_REPOSITORY')
    private inventoryRepository: typeof Inventory,
    @Inject('BRANDS_REPOSITORY')
    private brandsRepository: typeof Brand,
    @Inject('VEHICLE_MODELS_REPOSITORY')
    private vehicleModelsRepository: typeof VehicleModel,
    @Inject('VEHICLE_OWNERS_REPOSITORY')
    private vehicleOwnersRepository: typeof VehicleOwner,
  ){}
  create(createDashboardDto: CreateDashboardDto) {
    return 'This action adds a new dashboard';
  }

  async findAll() {
    var response = new GetDashboardData();
    let indianDate = new Date().toLocaleString("en-Us", {timeZone: 'Asia/Kolkata'});
    var totalBuyers = await this.buyersRepository.count();
    var totalOwners = await this.vehicleOwnersRepository.count();
    var totalOrders = await this.ordersRepository.count();
    var totalBrands = await this.brandsRepository.count();
    var totalModels = await this.vehicleModelsRepository.count();
    var totalInventory = await this.inventoryRepository.count();    
    var totalOrdersThisMonth = await this.ordersRepository.count({
      where:{
        month : (new Date(indianDate).getMonth() + 1),
        year : new Date(indianDate).getFullYear()
      }
    });
    var totalInventoryThisMonth = await this.inventoryRepository.count({
      where:{
        month : (new Date(indianDate).getMonth() + 1),
        year : new Date(indianDate).getFullYear()
      }
    });
    response.totalBrands = totalBrands;
    response.totalOwners = totalOwners;
    response.totalBuyers = totalBuyers;
    response.totalModels = totalModels;
    response.totalOrders = totalOrders;
    response.totalInventory = totalInventory;
    response.totalOrdersThisMonth = totalOrdersThisMonth;
    response.totalInventoryThisMonth = totalInventoryThisMonth;
    return response;
  }

  findOne(id: number) {
    return `This action returns a #${id} dashboard`;
  }

  update(id: number, updateDashboardDto: UpdateDashboardDto) {
    return `This action updates a #${id} dashboard`;
  }

  remove(id: number) {
    return `This action removes a #${id} dashboard`;
  }
}
