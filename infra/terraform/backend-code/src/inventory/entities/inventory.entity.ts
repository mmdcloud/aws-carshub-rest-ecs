import { Table, Column, Model, ForeignKey, BelongsTo } from 'sequelize-typescript';
import { VehicleModel } from 'src/vehicle-models/entities/vehicle-model.entity';
import { VehicleOwner } from 'src/vehicle-owners/entities/vehicle-owner.entity';

@Table
export class Inventory extends Model {

    @Column
    price: string;

    @Column
    color: string;

    @ForeignKey(() => VehicleModel)
    @Column
    modelId: number;

    @BelongsTo(() => VehicleModel)
    model: VehicleModel;

    @ForeignKey(() => VehicleOwner)
    @Column
    ownerId: number;

    @BelongsTo(() => VehicleOwner)
    owner: VehicleOwner;

    @Column
    day: number;

    @Column
    month: number;

    @Column
    year: number;

    @Column
    registrationYear: string;

    @Column
    passingCode: string;

    @Column
    kmsDriven: string;

    @Column
    engineCapacity: string;

    @Column
    variant: string;

    @Column
    fuelType: string;

    @Column
    transmission: string;

    @Column
    insurance: string;

    @Column
    ownership: string;

    @Column
    status: string;

    @Column
    airbags: string;

    @Column
    isofix: boolean;

    @Column
    abs: boolean;

    @Column
    centralLocking: boolean;

    @Column
    ebd: boolean;

    @Column
    tpms: boolean;

    @Column
    hillHoldControl: boolean;

    @Column
    hillDecentControl: boolean;

    @Column
    tractionControl: boolean;

    @Column
    rearDefogger: boolean;

    @Column
    frontFogLights: boolean;

    @Column
    instrumentPanelType: string;

    @Column
    bluetoothCompatibility: boolean;

    @Column
    steeringMountedControls: boolean;

    @Column
    audioSystem: boolean;

    @Column
    airConditioner: boolean;

    @Column
    powerWindowsFront: boolean;

    @Column
    steeringWheelMaterial: string;

    @Column
    parkingAssistRear: string;

    @Column
    powerOutlet12V: boolean

    @Column
    steeringAdjustment: boolean

    @Column
    seatUpholstery: string

    @Column
    pushButtonStart: boolean

    @Column
    cruiseControl: boolean

    @Column
    ventilatedSeatsFront: boolean

    @Column
    rearAC: boolean

    @Column
    displacement: string;

    @Column
    cylinders: string;

    @Column
    gearBoxNumberOfGears: string;

    @Column
    noOfDiscBrakes: string;

    @Column
    groundClearance: string;

    @Column
    seatingCapacity: string;

    @Column
    bootspace: string;

    @Column
    widthInMM: string;

    @Column
    lengthInMM: string;

    @Column
    wheelBaseInMM: string;

    @Column
    fuelTankCapacity: string;

    @Column
    maxPowerInBHP: string;

    @Column
    maxPowerInRPM: string;

    @Column
    emissionStandard: string;

    @Column
    maxTorqueInNM: string;

    @Column
    headlampLensType: string;

    @Column
    headlampBulbTypeHighBeam: string;

    @Column
    headlampBulbTypeLowBeam: string;

    @Column
    rimTypeFront: string;

    @Column
    rimTypeRear: string;

    @Column
    daytimeRunningLights: boolean;

    @Column
    electricallyFoldableMirrors: boolean;
}
