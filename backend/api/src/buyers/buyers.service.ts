import { Inject, Injectable } from '@nestjs/common';
import { UpdateBuyerDto } from './dto/update-buyer.dto';
import { Buyer } from './entities/buyer.entity';

@Injectable()
export class BuyersService {
  constructor(
    @Inject('BUYERS_REPOSITORY')
    private buyersRepository: typeof Buyer
  ) { }
  async create(createBuyerDto): Promise<Buyer> {
    const buyer = new Buyer(createBuyerDto);
    return await buyer.save();
  }

  async findAll(): Promise<Buyer[]> {
    return this.buyersRepository.findAll<Buyer>();
  }

  async findOne(id: number): Promise<Buyer> {
    return this.buyersRepository.findByPk<Buyer>(id);
  }

  async update(id: number, updateBuyerDto: UpdateBuyerDto): Promise<[number, Buyer[]]> {
    const [affectedCount, affectedRows] = await this.buyersRepository.update(updateBuyerDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as Buyer[]];
  }

  async remove(id: number): Promise<number> {
    return this.buyersRepository.destroy({ where: { id: id } });
  }
}
