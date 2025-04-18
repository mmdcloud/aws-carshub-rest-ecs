"use client";
import React from "react";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import InventoryDetailsCard from "../../../components/InventoryDetailsCard/InventoryDetailsCard";
import { useQuery } from "@tanstack/react-query";
import axiosInstance from "../../../network/axiosInstance";
import { useParams, useRouter } from "next/navigation";
import PageLoader from "@/components/common/Loader/pageLoader";
import DocumentsComponent from "@/components/DocumentsComponent/DocumentsComponent";
import CarouselComponent from "@/components/CarouselComponent/CarouselComponent";

const InventoryDetails = () => {
    const params = useParams();
    const router = useRouter();
    const { data, isLoading, error, isError } = useQuery({
        queryKey: ["inventory-details"],
        queryFn: () => {
            return axiosInstance.get("/inventory/" + params.id);
        }
    })
    return (
        <DefaultLayout>
            {
                isLoading ? <PageLoader /> :
                    <>
                        <div className="flex flex-row justify-end">
                            <button
                                onClick={() => {
                                    router.push("/inventory/" + params.id + "/upload");
                                }}
                                className="flex justify-center rounded bg-primary px-6 py-2 font-medium text-gray hover:bg-opacity-90"
                                type="button"
                            >
                                Upload Images/Documents
                            </button>
                        </div>
                        <div className="mt-4 grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-7.5 2xl:gap-7.5">
                            <div className="col-span-12 xl:col-span-8">
                                <CarouselComponent data={data.data.imageData} />
                            </div>
                            <DocumentsComponent data={data.data.documentData} />
                        </div>
                        <div className=" grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-7.5 2xl:gap-7.5">
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Id", "Model", "Owner"]} values={[data.data.inventoryData.id, data.data.inventoryData.model.name, data.data.inventoryData.owner.fullname]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Price", "Color", "Registration Year", "Passing Code"]} values={[data.data.inventoryData.price, data.data.inventoryData.color, data.data.inventoryData.registrationYear, data.data.inventoryData.passingCode]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Kms Driven", "Engine Capacity", "Variant", "Fuel Type"]} values={[data.data.inventoryData.kmsDriven, data.data.inventoryData.engineCapacity, data.data.inventoryData.variant, data.data.inventoryData.fuelType]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Transmission", "Insurance", "Ownership", "Airbags"]} values={[data.data.inventoryData.transmission, data.data.inventoryData.insurance, data.data.inventoryData.ownership, data.data.inventoryData.airbags]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Instrument Panel", "Steering Material", "Rear Park Assist","Seat Upholstery"]} values={[data.data.inventoryData.instrumentPanelType,data.data.inventoryData.steeringWheelMaterial, data.data.inventoryData.parkingAssistRear, data.data.inventoryData.seatUpholstery]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Displacement", "Cylinders", "No of Gears","No of Disc Brakes"]} values={[data.data.inventoryData.displacement, data.data.inventoryData.cylinders, data.data.inventoryData.noOfGears,data.data.inventoryData.noOfDiscBrakes]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Ground Clearance", "Seating Capacity", "Bootspace", "Width(in MM)"]} values={[data.data.inventoryData.groundClearance, data.data.inventoryData.seatingCapacity, data.data.inventoryData.bootspace, data.data.inventoryData.widthInMM]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Length(in MM)", "Wheelbase(in MM)", "Fuel Tank Capacity", "Max Power(in BHP)"]} values={[data.data.inventoryData.lengthInMM, data.data.inventoryData.wheelbase, data.data.inventoryData.fuelTankCapacity, data.data.inventoryData.maxPowerInBHP]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Max Power(in RPM)", "Emission Standard", "Max Torque(in NM)"]} values={[data.data.inventoryData.maxPowerInRPM, data.data.inventoryData.emissionStandard,  data.data.inventoryData.maxTorqueInNM]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Headlamp Lens Type", "Headlamp Bulb Type(High Beam)", "Headlamp Bulb Type(Low Beam)"]} values={[data.data.inventoryData.headlampLensType, data.data.inventoryData.model.name, data.data.inventoryData.owner.fullname]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Rim Type(Front)", "Rim Type(Rear)"]} values={[data.data.inventoryData.rimTypeFront, data.data.inventoryData.rimTypeRear]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Isofix", "ABS", "Central Locking", "EBD","TPMS"]} values={[data.data.inventoryData.isofix == false ? "No" : "Yes", data.data.inventoryData.abs == false ? "No" : "Yes", data.data.inventoryData.centralLocking == false ? "No" : "Yes", data.data.inventoryData.ebd == false ? "No" : "Yes" ,data.data.inventoryData.tpms == false ? "No" : "Yes" ]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Hill Hold Control", "Hill Descent Control", "Traction Control", "Rear Defogger","Front Fog Lights"]} values={[data.data.inventoryData.hillHoldControl == false ? "No" : "Yes", data.data.inventoryData.hillDecentControl == false ? "No" : "Yes", data.data.inventoryData.tractionControl  == false ? "No" : "Yes" , data.data.inventoryData.rearDefogger == false ? "No" : "Yes" ,data.data.inventoryData.frontFogLights == false ? "No" : "Yes" ]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Bluetooth Compatibility", "Steering Mounted Controls", "Audio System", "Air Conditioner","Power Windows(Front)"]} values={[data.data.inventoryData.bluetoothCompatibility == false ? "No" : "Yes" , data.data.inventoryData.steeringMountedControls == false ? "No" : "Yes", data.data.inventoryData.audioSystem == false ? "No" : "Yes" , data.data.inventoryData.airConditioner == false ? "No" : "Yes" ,data.data.inventoryData.powerWindowsFront == false ? "No" : "Yes" ]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Power Outlet(12V)", "Steering Adjustment", "Push Button Start","Cruise Control","Ventilated Seats(Front)"]} values={[data.data.inventoryData.powerOutlet12V == false ? "No" : "Yes", data.data.inventoryData.steeringAdjustment == false ? "No" : "Yes", data.data.inventoryData.pushButtonStart == false ? "No" : "Yes" ,data.data.inventoryData.cruiseControl == false ? "No" : "Yes" ,data.data.inventoryData.ventilatedSeatsFront == false ? "No" : "Yes" ]} />
                            </div>
                            <div className="col-span-12 xl:col-span-4">
                                <InventoryDetailsCard title={"Details"} keys={["Rear AC", "DRL", "Electrically Foldable Mirrors"]} values={[data.data.inventoryData.rearAC == false ? "No" : "Yes" , data.data.inventoryData.daytimeRunningLights == false ? "No" : "Yes" , data.data.inventoryData.electricallyFoldableMirrors == false ? "No" : "Yes" ]} />
                            </div>
                        </div>
                    </>
            }
        </DefaultLayout>
    );
};

export default InventoryDetails;
