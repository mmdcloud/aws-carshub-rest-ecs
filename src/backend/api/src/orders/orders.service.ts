import { Inject, Injectable } from '@nestjs/common';
import { UpdateOrderDto } from './dto/update-order.dto';
import { Order } from './entities/order.entity';
import { Inventory } from 'src/inventory/entities/inventory.entity';
import { ExtraService } from 'src/extra-services/entities/extra-service.entity';
import { GetOrderWithExtraServicesDto } from './dto/get-order-with-extra-services.dto';
import { ReportDto } from './dto/report.dto';
import { VehicleModel } from 'src/vehicle-models/entities/vehicle-model.entity';
import { Op } from 'sequelize';
import { VehicleOwner } from 'src/vehicle-owners/entities/vehicle-owner.entity';
import { Buyer } from 'src/buyers/entities/buyer.entity';

@Injectable()
export class OrdersService {
  constructor(
    @Inject('EXTRA_SERVICES_REPOSITORY')
    private extraServicesRepository: typeof ExtraService,
    @Inject('ORDERS_REPOSITORY')
    private ordersRepository: typeof Order,
    @Inject('INVENTORY_REPOSITORY')
    private inventoryRepository: typeof Inventory
  ) { }
  async create(createOrderDto): Promise<Order> {
    var order = new Order(createOrderDto);
    order.day = parseInt(createOrderDto.date.split("-")[2]);
    order.month = parseInt(createOrderDto.date.split("-")[1]);
    order.year = parseInt(createOrderDto.date.split("-")[0]);
    await this.inventoryRepository.update({
      status: "Completed"
    }, {
      where: {
        id: order.inventoryId
      }
    });
    return await order.save();
  }

  async findAll(): Promise<Order[]> {
    return this.ordersRepository.findAll<Order>({
      include: ["buyer", "inventory"]
    });
  }

  async findOne(id: number): Promise<Order> {
    return this.ordersRepository.findByPk<Order>(id, {
      include: ["buyer", "inventory"]
    });
  }

  // async generateInvoice(id: number): Promise<Uint8Array> {
  //   try {
  //     const browser = await puppeteer.launch({headless:true,executablePath: '/usr/bin/google-chrome-stable',
  //       args: ['--no-sandbox']});
  //     const page = await browser.newPage();
  //     await page.goto('http://localhost:3000/index.html', { waitUntil: 'networkidle0' });
  //     const pdf = await page.pdf({ format: 'A4', });
  //     await browser.close();
  //     return pdf;
  //   }
  //   catch (e) {
  //     console.log(e);
  //   }
  // }

  async generateReport(reportDto: ReportDto): Promise<any> {
    var fromDate = new Date(reportDto.fromDate);
    var toDate = new Date(reportDto.toDate);
    return this.ordersRepository.findAll({
      where: {
        [Op.and]: [{ createdAt: { [Op.gte]: fromDate } }, { createdAt: { [Op.lte]: toDate } }],
      },
      include: [{
        model: Buyer, attributes: ["id", "fullname"]
      }, {
        model: Inventory, attributes: ["id", "modelId", "ownerId","status","price"], include: [{
          model: VehicleModel, include: ["brand"]
        }, {
          model: VehicleOwner, attributes: ["id", "fullname"]
        }]
      }]
    });
  }

  async downloadInvoice(id: number): Promise<Order> {
    return this.ordersRepository.findByPk<Order>(id, {
      include: ["buyer", "inventory"]
    });
  }

  async getOrderDetailsWithExtraServices(id: string): Promise<GetOrderWithExtraServicesDto> {
    var response = new GetOrderWithExtraServicesDto();
    var orderData = await this.ordersRepository.findByPk<Order>(id, {
      include: [{
        model: Buyer, attributes: ["id", "fullname","email","city","contact"]
      }, {
        model: Inventory, attributes: ["id", "modelId", "ownerId","status","price"], include: [{
          model: VehicleModel, include: ["brand"]
        }, {
          model: VehicleOwner, attributes: ["id", "fullname"]
        }]
      }]
    });
    var extraServicesData = await this.extraServicesRepository.findAll<ExtraService>({
      where: {
        orderId: parseInt(id)
      }
    });
    response.orderData = orderData;
    response.extraServices = extraServicesData;
    return response;
  }

  async update(id: number, updateOrderDto: UpdateOrderDto): Promise<[number, Order[]]> {
    const [affectedCount, affectedRows] = await this.ordersRepository.update(updateOrderDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as Order[]];
  }

  async remove(id: number): Promise<number> {
    return this.ordersRepository.destroy({ where: { id: id } });
  }
}
