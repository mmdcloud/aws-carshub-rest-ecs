import { Inject, Injectable } from '@nestjs/common';
import { UpdateBrandDto } from './dto/update-brand.dto';
import { Brand } from './entities/brand.entity';

@Injectable()
export class BrandsService {
  constructor(
    @Inject('BRANDS_REPOSITORY')
    private brandsRepository: typeof Brand
  ) { }
  async create(createBrandDto): Promise<Brand> {
    const brand = new Brand(createBrandDto);
    return await brand.save();
  }

  async findAll(): Promise<Brand[]> {
    return this.brandsRepository.findAll<Brand>();
  }

  async findOne(id: number): Promise<Brand> {
    return this.brandsRepository.findByPk<Brand>(id);
  }

  async update(id: number, updateBrandDto: UpdateBrandDto): Promise<[number, Brand[]]> {
    const [affectedCount, affectedRows] = await this.brandsRepository.update(updateBrandDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as Brand[]];
  }

  async remove(id: number): Promise<number> {
    return this.brandsRepository.destroy({ where: { id: id } });
  }
}
