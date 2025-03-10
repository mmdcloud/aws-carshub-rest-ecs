import { Inject, Injectable } from '@nestjs/common';
import { UpdateInventoryDto } from './dto/update-inventory.dto';
import { Inventory } from './entities/inventory.entity';
import { InventoryImage } from './entities/inventory-image.entity';
import { InventoryDetailsDto } from './dto/inventory-details.dto';
import { S3Client } from "@aws-sdk/client-s3";
import { PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { GetSignedUrlConfig, GetSignedUrlResponse, Storage } from '@google-cloud/storage';

const AWS = require('aws-sdk');
const s3 = new AWS.S3({ signatureVersion: 'v4', });

const s3Client = new S3Client({ region: 'us-east-1' });

@Injectable()
export class InventoryService {
  constructor(
    @Inject('INVENTORY_REPOSITORY')
    private inventoryRepository: typeof Inventory,
    @Inject('INVENTORY_IMAGES_REPOSITORY')
    private inventoryImagesRepository: typeof InventoryImage
  ) { }

  async getSignedUrl(payload): Promise<string> {
    const storage = new Storage();
    const bucket = storage.bucket("carshub-media");
    const file = bucket.file(payload.file);    
    var options : GetSignedUrlConfig = {
      action: 'write',
      version:"v4",
      expires: Date.now() + 3600 * 1000,
      contentType: payload.mime_type,
      extensionHeaders:{
        // 'Content-Type': "application/octet-stream",
        "x-goog-meta-typeofdocument": payload.type,
        "x-goog-meta-descriptionofdocument": payload.description,
        "x-goog-meta-inventoryid": payload.inventoryId
      }
    } 
    // Generate the signed URL
    const [url] = await file.getSignedUrl(options);
    console.log(url);
    return url;
  }

  async create(createInventoryDto): Promise<Inventory> {
    const record = new Inventory(createInventoryDto);
    let indianDate = new Date().toLocaleString("en-Us", { timeZone: 'Asia/Kolkata' });
    record.day = new Date(indianDate).getDay();
    record.month = (new Date(indianDate).getMonth() + 1);
    record.year = new Date(indianDate).getFullYear();
    record.status = "Pending";
    return await record.save();
  }

  async findAll(): Promise<Inventory[]> {
    return this.inventoryRepository.findAll<Inventory>({
      include: ["model", "owner"]
    });
  }

  async findOne(id: number): Promise<InventoryDetailsDto> {
    var response = new InventoryDetailsDto();
    var imageData = await this.inventoryImagesRepository.findAll({
      attributes: ['type', 'path', 'inventoryId'],
      where: {
        inventoryId: id,
        type: "image"
      }
    });
    var documentData = await this.inventoryImagesRepository.findAll({
      attributes: ['type', 'path', 'inventoryId'],
      where: {
        inventoryId: id,
        type: "document"
      }
    });
    var inventoryData = await this.inventoryRepository.findByPk<Inventory>(id, {
      include: ["model", "owner"]
    });
    response.imageData = imageData;
    response.documentData = documentData;
    response.inventoryData = inventoryData;
    return response;
  }

  async update(id: number, updateInventoryDto: UpdateInventoryDto): Promise<[number, Inventory[]]> {
    const [affectedCount, affectedRows] = await this.inventoryRepository.update(updateInventoryDto, {
      where: { id },
      returning: true,
    });
    return [affectedCount, affectedRows as Inventory[]];
  }

  async remove(id: number): Promise<number> {
    return this.inventoryRepository.destroy({ where: { id: id } });
  }
}
