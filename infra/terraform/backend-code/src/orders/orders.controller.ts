import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { AuthGuard } from 'src/auth.guard';
import { OrderWithExtraServicesRequestDto } from './dto/order-with-extra-services-request.dto';
import { ReportDto } from './dto/report.dto';

@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @UseGuards(AuthGuard)
  @Get('/downloadInvoice')
  downloadInvoice(@Param('id') id: string) {
    return this.ordersService.downloadInvoice(+id);
  }

  // @UseGuards(AuthGuard)
  // @Get("/generateInvoice/:id")
  // generateInvoice(@Param('id') id: string) {
  //   return this.ordersService.generateInvoice(+id);
  // }

  @UseGuards(AuthGuard)
  @Post("/generateReport")
  generateReport(@Body() reportDto: ReportDto) {
    return this.ordersService.generateReport(reportDto);
  }

  @UseGuards(AuthGuard)
  @Get('/getOrderDetailsWithExtraServices/:id')
  getOrderDetailsWithExtraServices(@Param('id') id: string) {
    return this.ordersService.getOrderDetailsWithExtraServices(id);
  }

  @UseGuards(AuthGuard)
  @Post()
  create(@Body() createOrderDto: CreateOrderDto) {
    return this.ordersService.create(createOrderDto);
  }

  @UseGuards(AuthGuard)
  @Get()
  findAll() {
    return this.ordersService.findAll();
  }

  @UseGuards(AuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(+id);
  }

  @UseGuards(AuthGuard)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateOrderDto: UpdateOrderDto) {
    return this.ordersService.update(+id, updateOrderDto);
  }

  @UseGuards(AuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ordersService.remove(+id);
  }
}
