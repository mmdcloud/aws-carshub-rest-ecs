"use client";
import { useMutation, useQuery } from "@tanstack/react-query";
import { useFormik } from "formik";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import axiosInstance from "../../../network/axiosInstance";
import toast from "react-hot-toast";
import SwitcherOne from "@/components/Switchers/SwitcherOne";
import { useSearchParams } from "next/navigation";
import { useEffect } from "react";
import PageLoader from "@/components/common/Loader/pageLoader";

const InventoryForm = () => {
    const params = useSearchParams();
    const { data: models } = useQuery({
        queryKey: ["vehicle-models"],
        queryFn: () => {
            return axiosInstance.get("/vehicle-models");
        }
    })
    const { data: owners } = useQuery({
        queryKey: ["vehicle-owners"],
        queryFn: () => {
            return axiosInstance.get("/vehicle-owners");
        }
    })
    const formik = useFormik({
        initialValues: {
            id: '',
            modelId: '',
            ownerId: '',
            price: '',
            color: '',
            registrationYear: '',
            passingCode: '',
            kmsDriven: '',
            engineCapacity: '',
            variant: '',
            fuelType: '',
            transmission: '',
            insurance: '',
            ownership: '',
            status: '',
            airbags: '',
            instrumentPanelType: '',
            steeringWheelMaterial: '',
            parkingAssistRear: '',
            seatUpholstery: '',
            displacement: '',
            cylinders: '',
            gearBoxNumberOfGears: '',
            noOfDiscBrakes: '',
            groundClearance: '',
            seatingCapacity: '',
            bootspace: '',
            widthInMM: '',
            lengthInMM: '',
            wheelBaseInMM: '',
            fuelTankCapacity: '',
            maxPowerInBHP: '',
            maxPowerInRPM: '',
            emissionStandard: '',
            maxTorqueInNM: '',
            headlampLensType: '',
            headlampBulbTypeHighBeam: '',
            headlampBulbTypeLowBeam: '',
            rimTypeFront: '',
            rimTypeRear: '',
            isofix: params.get("id") !== null ? params.get("isofix") === "false" ? false  : true : false,
            abs: params.get("id") !== null ? params.get("abs") === "false" ? false  : true : false,
            centralLocking: params.get("id") !== null ? params.get("centralLocking") === "false" ? false  : true : false,
            ebd: params.get("id") !== null ? params.get("ebd") === "false" ? false  : true : false,
            tpms: params.get("id") !== null ? params.get("tpms") === "false" ? false  : true : false,
            hillHoldControl: params.get("id") !== null ? params.get("hillHoldControl") === "false" ? false  : true : false,
            hillDecentControl: params.get("id") !== null ? params.get("hillDecentControl") === "false" ? false  : true : false,
            tractionControl: params.get("id") !== null ? params.get("tractionControl") === "false" ? false  : true : false,
            rearDefogger: params.get("id") !== null ? params.get("rearDefogger") === "false" ? false  : true : false,
            frontFogLights: params.get("id") !== null ? params.get("frontFogLights") === "false" ? false  : true : false,
            bluetoothCompatibility: params.get("id") !== null ? params.get("bluetoothCompatibility") === "false" ? false  : true : false,
            steeringMountedControls: params.get("id") !== null ? params.get("steeringMountedControls") === "false" ? false  : true : false,
            audioSystem: params.get("id") !== null ? params.get("audioSystem") === "false" ? false  : true : false,
            airConditioner: params.get("id") !== null ? params.get("airConditioner") === "false" ? false  : true : false,
            powerWindowsFront: params.get("id") !== null ? params.get("powerWindowsFront") === "false" ? false  : true : false,
            powerOutlet12V: params.get("id") !== null ? params.get("powerOutlet12V") === "false" ? false  : true : false,
            steeringAdjustment: params.get("id") !== null ? params.get("steeringAdjustment") === "false" ? false  : true : false,
            pushButtonStart: params.get("id") !== null ? params.get("pushButtonStart") === "false" ? false  : true : false,
            cruiseControl: params.get("id") !== null ? params.get("cruiseControl") === "false" ? false  : true : false,
            ventilatedSeatsFront: params.get("id") !== null ? params.get("ventilatedSeatsFront") === "false" ? false  : true : false,
            rearAC: params.get("id") !== null ? params.get("rearAC") === "false" ? false  : true : false,
            daytimeRunningLights: params.get("id") !== null ? params.get("daytimeRunningLights") === "false" ? false  : true : false,
            electricallyFoldableMirrors: params.get("id") !== null ? params.get("electricallyFoldableMirrors") === "false" ? false  : true : false
        },
        onSubmit: (values) => {
            if (params.get("id") !== null) {
                updateMutation.mutate(values);
            }
            else {
                delete values.id;
                mutation.mutate(values);
            }
        }
    });

    useEffect(() => {        
        if (params.get("id") !== null) {
            for (let [key, value] of params) {                                
                formik.setFieldValue(key, value);                                
            }
        }
    }, []);

    const mutation = useMutation({
        mutationFn: (payload) => {
            return axiosInstance.post('/inventory', payload);
        },
        onSuccess: (data, variables, context) => {
            toast.success("Created successfully !");
        },
        onError: (error, variables, context) => {
            toast.success("Something went wrong !");
        }
    })
    const updateMutation = useMutation({
        mutationFn: (payload) => {
            return axiosInstance.patch('/inventory/' + params.get("id"), payload);
        },
        onSuccess: (data, variables, context) => {
            toast.success("Updated successfully !");
        },
        onError: (error, variables, context) => {
            toast.error("Something went wrong !");
        }
    })
    return (
        <DefaultLayout>
            <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
                <div className="border-b border-stroke px-6.5 py-4 dark:border-strokedark">
                    <h3 className="font-medium text-black dark:text-white">
                        Inventory Form
                    </h3>
                </div>
                <form onSubmit={formik.handleSubmit}>
                    <div className="p-6.5">
                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/2">
                                <div className="mb-5.5">
                                    <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                        Model
                                    </label>

                                    <div className="relative z-20 bg-white dark:bg-form-input">
                                        <span className="absolute left-4 top-1/2 z-30 -translate-y-1/2">
                                            <svg
                                                width="20"
                                                height="20"
                                                viewBox="0 0 20 20"
                                                fill="none"
                                                xmlns="http://www.w3.org/2000/svg"
                                            >
                                                <g opacity="0.8">
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M10.0007 2.50065C5.85852 2.50065 2.50065 5.85852 2.50065 10.0007C2.50065 14.1428 5.85852 17.5007 10.0007 17.5007C14.1428 17.5007 17.5007 14.1428 17.5007 10.0007C17.5007 5.85852 14.1428 2.50065 10.0007 2.50065ZM0.833984 10.0007C0.833984 4.93804 4.93804 0.833984 10.0007 0.833984C15.0633 0.833984 19.1673 4.93804 19.1673 10.0007C19.1673 15.0633 15.0633 19.1673 10.0007 19.1673C4.93804 19.1673 0.833984 15.0633 0.833984 10.0007Z"
                                                        fill="#637381"
                                                    ></path>
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M0.833984 9.99935C0.833984 9.53911 1.20708 9.16602 1.66732 9.16602H18.334C18.7942 9.16602 19.1673 9.53911 19.1673 9.99935C19.1673 10.4596 18.7942 10.8327 18.334 10.8327H1.66732C1.20708 10.8327 0.833984 10.4596 0.833984 9.99935Z"
                                                        fill="#637381"
                                                    ></path>
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M7.50084 10.0008C7.55796 12.5632 8.4392 15.0301 10.0006 17.0418C11.5621 15.0301 12.4433 12.5632 12.5005 10.0008C12.4433 7.43845 11.5621 4.97153 10.0007 2.95982C8.4392 4.97153 7.55796 7.43845 7.50084 10.0008ZM10.0007 1.66749L9.38536 1.10547C7.16473 3.53658 5.90275 6.69153 5.83417 9.98346C5.83392 9.99503 5.83392 10.0066 5.83417 10.0182C5.90275 13.3101 7.16473 16.4651 9.38536 18.8962C9.54325 19.069 9.76655 19.1675 10.0007 19.1675C10.2348 19.1675 10.4581 19.069 10.6159 18.8962C12.8366 16.4651 14.0986 13.3101 14.1671 10.0182C14.1674 10.0066 14.1674 9.99503 14.1671 9.98346C14.0986 6.69153 12.8366 3.53658 10.6159 1.10547L10.0007 1.66749Z"
                                                        fill="#637381"
                                                    ></path>
                                                </g>
                                            </svg>
                                        </span>

                                        <select
                                            id="modelId"
                                            name="modelId"
                                            onChange={formik.handleChange}
                                            value={formik.values.modelId}
                                            className={`relative z-20 w-full appearance-none rounded border border-stroke bg-transparent px-12 py-3 outline-none transition focus:border-primary active:border-primary dark:border-form-strokedark dark:bg-form-input `}
                                        >
                                            <option value="" disabled className="text-body dark:text-bodydark">
                                                Select Model
                                            </option>
                                            {
                                                models && models.data.map((x,key) => {
                                                    return <option key={key} value={x.id} className="text-body dark:text-bodydark">
                                                        {x.name}
                                                    </option>
                                                })
                                            }
                                        </select>
                                        <span className="absolute right-4 top-1/2 z-10 -translate-y-1/2">
                                            <svg
                                                width="24"
                                                height="24"
                                                viewBox="0 0 24 24"
                                                fill="none"
                                                xmlns="http://www.w3.org/2000/svg"
                                            >
                                                <g opacity="0.8">
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M5.29289 8.29289C5.68342 7.90237 6.31658 7.90237 6.70711 8.29289L12 13.5858L17.2929 8.29289C17.6834 7.90237 18.3166 7.90237 18.7071 8.29289C19.0976 8.68342 19.0976 9.31658 18.7071 9.70711L12.7071 15.7071C12.3166 16.0976 11.6834 16.0976 11.2929 15.7071L5.29289 9.70711C4.90237 9.31658 4.90237 8.68342 5.29289 8.29289Z"
                                                        fill="#637381"
                                                    ></path>
                                                </g>
                                            </svg>
                                        </span>
                                    </div>
                                    {formik.errors.modelId && formik.touched.modelId ? (
                                        <div className="text-red mt-2">{formik.errors.modelId}</div>
                                    ) : null}
                                </div>
                            </div>

                            <div className="w-full xl:w-1/2">
                                <div className="mb-5.5">
                                    <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                        Owner
                                    </label>

                                    <div className="relative z-20 bg-white dark:bg-form-input">
                                        <span className="absolute left-4 top-1/2 z-30 -translate-y-1/2">
                                            <svg
                                                width="20"
                                                height="20"
                                                viewBox="0 0 20 20"
                                                fill="none"
                                                xmlns="http://www.w3.org/2000/svg"
                                            >
                                                <g opacity="0.8">
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M10.0007 2.50065C5.85852 2.50065 2.50065 5.85852 2.50065 10.0007C2.50065 14.1428 5.85852 17.5007 10.0007 17.5007C14.1428 17.5007 17.5007 14.1428 17.5007 10.0007C17.5007 5.85852 14.1428 2.50065 10.0007 2.50065ZM0.833984 10.0007C0.833984 4.93804 4.93804 0.833984 10.0007 0.833984C15.0633 0.833984 19.1673 4.93804 19.1673 10.0007C19.1673 15.0633 15.0633 19.1673 10.0007 19.1673C4.93804 19.1673 0.833984 15.0633 0.833984 10.0007Z"
                                                        fill="#637381"
                                                    ></path>
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M0.833984 9.99935C0.833984 9.53911 1.20708 9.16602 1.66732 9.16602H18.334C18.7942 9.16602 19.1673 9.53911 19.1673 9.99935C19.1673 10.4596 18.7942 10.8327 18.334 10.8327H1.66732C1.20708 10.8327 0.833984 10.4596 0.833984 9.99935Z"
                                                        fill="#637381"
                                                    ></path>
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M7.50084 10.0008C7.55796 12.5632 8.4392 15.0301 10.0006 17.0418C11.5621 15.0301 12.4433 12.5632 12.5005 10.0008C12.4433 7.43845 11.5621 4.97153 10.0007 2.95982C8.4392 4.97153 7.55796 7.43845 7.50084 10.0008ZM10.0007 1.66749L9.38536 1.10547C7.16473 3.53658 5.90275 6.69153 5.83417 9.98346C5.83392 9.99503 5.83392 10.0066 5.83417 10.0182C5.90275 13.3101 7.16473 16.4651 9.38536 18.8962C9.54325 19.069 9.76655 19.1675 10.0007 19.1675C10.2348 19.1675 10.4581 19.069 10.6159 18.8962C12.8366 16.4651 14.0986 13.3101 14.1671 10.0182C14.1674 10.0066 14.1674 9.99503 14.1671 9.98346C14.0986 6.69153 12.8366 3.53658 10.6159 1.10547L10.0007 1.66749Z"
                                                        fill="#637381"
                                                    ></path>
                                                </g>
                                            </svg>
                                        </span>

                                        <select
                                            id="ownerId"
                                            name="ownerId"
                                            onChange={formik.handleChange}
                                            value={formik.values.ownerId}
                                            className={`relative z-20 w-full appearance-none rounded border border-stroke bg-transparent px-12 py-3 outline-none transition focus:border-primary active:border-primary dark:border-form-strokedark dark:bg-form-input `}
                                        >
                                            <option value="" disabled className="text-body dark:text-bodydark">
                                                Select Owner
                                            </option>
                                            {
                                                owners && owners.data.map((x,key) => {
                                                    return <option key={key} value={x.id} className="text-body dark:text-bodydark">
                                                        {x.fullname}
                                                    </option>
                                                })
                                            }
                                        </select>
                                        <span className="absolute right-4 top-1/2 z-10 -translate-y-1/2">
                                            <svg
                                                width="24"
                                                height="24"
                                                viewBox="0 0 24 24"
                                                fill="none"
                                                xmlns="http://www.w3.org/2000/svg"
                                            >
                                                <g opacity="0.8">
                                                    <path
                                                        fillRule="evenodd"
                                                        clipRule="evenodd"
                                                        d="M5.29289 8.29289C5.68342 7.90237 6.31658 7.90237 6.70711 8.29289L12 13.5858L17.2929 8.29289C17.6834 7.90237 18.3166 7.90237 18.7071 8.29289C19.0976 8.68342 19.0976 9.31658 18.7071 9.70711L12.7071 15.7071C12.3166 16.0976 11.6834 16.0976 11.2929 15.7071L5.29289 9.70711C4.90237 9.31658 4.90237 8.68342 5.29289 8.29289Z"
                                                        fill="#637381"
                                                    ></path>
                                                </g>
                                            </svg>
                                        </span>
                                    </div>
                                    {formik.errors.ownerId && formik.touched.ownerId ? (
                                        <div className="text-red mt-2">{formik.errors.ownerId}</div>
                                    ) : null}
                                </div>
                            </div>
                        </div>
                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Price
                                </label>
                                <input
                                    type="text"
                                    id="price"
                                    name="price"
                                    onChange={formik.handleChange}
                                    value={formik.values.price}
                                    placeholder="Price"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Color
                                </label>
                                <input
                                    type="text"
                                    id="color"
                                    name="color"
                                    onChange={formik.handleChange}
                                    value={formik.values.color}
                                    placeholder="Color"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Registration Year
                                </label>
                                <input
                                    type="text"
                                    id="registrationYear"
                                    name="registrationYear"
                                    onChange={formik.handleChange}
                                    value={formik.values.registrationYear}
                                    placeholder="Registration Year"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Passing Code
                                </label>
                                <input
                                    type="text"
                                    id="passingCode"
                                    name="passingCode"
                                    onChange={formik.handleChange}
                                    value={formik.values.passingCode}
                                    placeholder="Passing Code"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Kms Driven
                                </label>
                                <input
                                    type="text"
                                    id="kmsDriven"
                                    name="kmsDriven"
                                    onChange={formik.handleChange}
                                    value={formik.values.kmsDriven}
                                    placeholder="Kms Driven"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Engine Capacity
                                </label>
                                <input
                                    type="text"
                                    id="engineCapacity"
                                    name="engineCapacity"
                                    onChange={formik.handleChange}
                                    value={formik.values.engineCapacity}
                                    placeholder="Engine Capacity"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Variant
                                </label>
                                <input
                                    type="text"
                                    id="variant"
                                    name="variant"
                                    onChange={formik.handleChange}
                                    value={formik.values.variant}
                                    placeholder="Variant"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Fuel Type
                                </label>
                                <input
                                    type="text"
                                    id="fuelType"
                                    name="fuelType"
                                    onChange={formik.handleChange}
                                    value={formik.values.fuelType}
                                    placeholder="Fuel Type"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Transmission
                                </label>
                                <input
                                    type="text"
                                    id="transmission"
                                    name="transmission"
                                    onChange={formik.handleChange}
                                    value={formik.values.transmission}
                                    placeholder="Transmission"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Insurance
                                </label>
                                <input
                                    type="text"
                                    id="insurance"
                                    name="insurance"
                                    onChange={formik.handleChange}
                                    value={formik.values.insurance}
                                    placeholder="Insurance"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Ownership
                                </label>
                                <input
                                    type="text"
                                    id="ownership"
                                    name="ownership"
                                    onChange={formik.handleChange}
                                    value={formik.values.ownership}
                                    placeholder="Ownership"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Airbags
                                </label>
                                <input
                                    type="text"
                                    id="airbags"
                                    name="airbags"
                                    onChange={formik.handleChange}
                                    value={formik.values.airbags}
                                    placeholder="Airbags"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Instrument Panel Type
                                </label>
                                <input
                                    type="text"
                                    id="instrumentPanelType"
                                    name="instrumentPanelType"
                                    onChange={formik.handleChange}
                                    value={formik.values.instrumentPanelType}
                                    placeholder="Instrument Panel Type"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Steering Wheel Material
                                </label>
                                <input
                                    type="text"
                                    id="steeringWheelMaterial"
                                    name="steeringWheelMaterial"
                                    onChange={formik.handleChange}
                                    value={formik.values.steeringWheelMaterial}
                                    placeholder="Steering Wheel Material"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Parking Assist Rear
                                </label>
                                <input
                                    type="text"
                                    id="parkingAssistRear"
                                    name="parkingAssistRear"
                                    onChange={formik.handleChange}
                                    value={formik.values.parkingAssistRear}
                                    placeholder="Parking Assist Rear"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Seat Upholstery
                                </label>
                                <input
                                    type="text"
                                    id="seatUpholstery"
                                    name="seatUpholstery"
                                    onChange={formik.handleChange}
                                    value={formik.values.seatUpholstery}
                                    placeholder="Seat Upholstery"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Displacement
                                </label>
                                <input
                                    type="text"
                                    id="displacement"
                                    name="displacement"
                                    onChange={formik.handleChange}
                                    value={formik.values.displacement}
                                    placeholder="Displacement"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Cylinders
                                </label>
                                <input
                                    type="text"
                                    id="cylinders"
                                    name="cylinders"
                                    onChange={formik.handleChange}
                                    value={formik.values.cylinders}
                                    placeholder="Cylinders"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    No of Gears
                                </label>
                                <input
                                    type="text"
                                    id="gearBoxNumberOfGears"
                                    name="gearBoxNumberOfGears"
                                    onChange={formik.handleChange}
                                    value={formik.values.gearBoxNumberOfGears}
                                    placeholder="No of Gears"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    No of Disc Brakes
                                </label>
                                <input
                                    type="text"
                                    id="noOfDiscBrakes"
                                    name="noOfDiscBrakes"
                                    onChange={formik.handleChange}
                                    value={formik.values.noOfDiscBrakes}
                                    placeholder="No of Disc Brakes"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Ground Clearance
                                </label>
                                <input
                                    type="text"
                                    id="groundClearance"
                                    name="groundClearance"
                                    onChange={formik.handleChange}
                                    value={formik.values.groundClearance}
                                    placeholder="Ground Clearance"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Seating Capacity
                                </label>
                                <input
                                    type="text"
                                    id="seatingCapacity"
                                    name="seatingCapacity"
                                    onChange={formik.handleChange}
                                    value={formik.values.seatingCapacity}
                                    placeholder="Seating Capacity"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Bootspace
                                </label>
                                <input
                                    type="text"
                                    id="bootspace"
                                    name="bootspace"
                                    onChange={formik.handleChange}
                                    value={formik.values.bootspace}
                                    placeholder="Bootspace"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Width (in MM)
                                </label>
                                <input
                                    type="text"
                                    id="widthInMM"
                                    name="widthInMM"
                                    onChange={formik.handleChange}
                                    value={formik.values.widthInMM}
                                    placeholder="Width (in MM)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Length (in MM)
                                </label>
                                <input
                                    type="text"
                                    id="lengthInMM"
                                    name="lengthInMM"
                                    onChange={formik.handleChange}
                                    value={formik.values.lengthInMM}
                                    placeholder="Length (in MM)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Wheelbase (in MM)
                                </label>
                                <input
                                    type="text"
                                    id="wheelBaseInMM"
                                    name="wheelBaseInMM"
                                    onChange={formik.handleChange}
                                    value={formik.values.wheelBaseInMM}
                                    placeholder="Wheelbase (in MM)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Fuel Tank Capacity
                                </label>
                                <input
                                    type="text"
                                    id="fuelTankCapacity"
                                    name="fuelTankCapacity"
                                    onChange={formik.handleChange}
                                    value={formik.values.fuelTankCapacity}
                                    placeholder="Fuel Tank Capacity"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Max Power (in BHP)
                                </label>
                                <input
                                    type="text"
                                    id="maxPowerInBHP"
                                    name="maxPowerInBHP"
                                    onChange={formik.handleChange}
                                    value={formik.values.maxPowerInBHP}
                                    placeholder="Max Power (in BHP)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Max Power (in RPM)
                                </label>
                                <input
                                    type="text"
                                    id="maxPowerInRPM"
                                    name="maxPowerInRPM"
                                    onChange={formik.handleChange}
                                    value={formik.values.maxPowerInRPM}
                                    placeholder="Max Power (in RPM)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Emission Standard
                                </label>
                                <input
                                    type="text"
                                    id="emissionStandard"
                                    name="emissionStandard"
                                    onChange={formik.handleChange}
                                    value={formik.values.emissionStandard}
                                    placeholder="Emission Standard"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Max Torque( in NM)
                                </label>
                                <input
                                    type="text"
                                    id="maxTorqueInNM"
                                    name="maxTorqueInNM"
                                    onChange={formik.handleChange}
                                    value={formik.values.maxTorqueInNM}
                                    placeholder="Max Torque( in NM)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Headlamp Lens Type
                                </label>
                                <input
                                    type="text"
                                    id="headlampLensType"
                                    name="headlampLensType"
                                    onChange={formik.handleChange}
                                    value={formik.values.headlampLensType}
                                    placeholder="Headlamp Lens Type"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Headlamb Bulb Type High Beam
                                </label>
                                <input
                                    type="text"
                                    id="headlampBulbTypeHighBeam"
                                    name="headlampBulbTypeHighBeam"
                                    onChange={formik.handleChange}
                                    value={formik.values.headlampBulbTypeHighBeam}
                                    placeholder="Headlamb Bulb Type High Beam"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Headlamb Bulb Type Low Beam
                                </label>
                                <input
                                    type="text"
                                    id="headlampBulbTypeLowBeam"
                                    name="headlampBulbTypeLowBeam"
                                    onChange={formik.handleChange}
                                    value={formik.values.headlampBulbTypeLowBeam}
                                    placeholder="Headlamb Bulb Type Low Beam"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Rim Type (Front)
                                </label>
                                <input
                                    type="text"
                                    id="rimTypeFront"
                                    name="rimTypeFront"
                                    onChange={formik.handleChange}
                                    value={formik.values.rimTypeFront}
                                    placeholder="Rim Type (Front)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>

                            <div className="w-full xl:w-1/4">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Rim Type (Rear)
                                </label>
                                <input
                                    type="text"
                                    id="rimTypeRear"
                                    name="rimTypeRear"
                                    onChange={formik.handleChange}
                                    value={formik.values.rimTypeRear}
                                    placeholder="Rim Type (Rear)"
                                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                                />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Isofix
                                </label>
                                <SwitcherOne meta={"isofix"} value={formik.values.isofix} onChange={(item) => {
                                    formik.setFieldValue("isofix", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    ABS
                                </label>
                                <SwitcherOne meta={"abs"} value={formik.values.abs} onChange={(item) => {
                                    formik.setFieldValue("abs", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Central Locking
                                </label>
                                <SwitcherOne meta={"centralLocking"} value={formik.values.centralLocking} onChange={(item) => {
                                    formik.setFieldValue("centralLocking", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    EBD
                                </label>
                                <SwitcherOne meta={"ebd"} value={formik.values.ebd} onChange={(item) => {
                                    formik.setFieldValue("ebd", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    TPMS
                                </label>
                                <SwitcherOne meta={"tpms"} value={formik.values.tpms} onChange={(item) => {
                                    formik.setFieldValue("tpms", item);
                                }} />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Hill Hold Control
                                </label>
                                <SwitcherOne meta={"hillHoldControl"} value={formik.values.hillHoldControl} onChange={(item) => {
                                    formik.setFieldValue("hillHoldControl", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Hill Descent Control
                                </label>
                                <SwitcherOne meta={"hillDecentControl"} value={formik.values.hillDecentControl} onChange={(item) => {
                                    formik.setFieldValue("hillDecentControl", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Traction Control
                                </label>
                                <SwitcherOne meta={"tractionControl"} value={formik.values.tractionControl} onChange={(item) => {
                                    formik.setFieldValue("tractionControl", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Rear Defogger
                                </label>
                                <SwitcherOne meta={"rearDefogger"} value={formik.values.rearDefogger} onChange={(item) => {
                                    formik.setFieldValue("rearDefogger", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Front Fog Lights
                                </label>
                                <SwitcherOne meta={"frontFogLights"} value={formik.values.frontFogLights} onChange={(item) => {
                                    formik.setFieldValue("frontFogLights", item);
                                }} />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Bluetooth Compatibility
                                </label>
                                <SwitcherOne meta={"bluetoothCompatibility"} value={formik.values.bluetoothCompatibility} onChange={(item) => {
                                    formik.setFieldValue("bluetoothCompatibility", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Steering Mounted Controls
                                </label>
                                <SwitcherOne meta={"steeringMountedControls"} value={formik.values.steeringMountedControls} onChange={(item) => {
                                    formik.setFieldValue("steeringMountedControls", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Audio System
                                </label>
                                <SwitcherOne meta={"audioSystem"} value={formik.values.audioSystem} onChange={(item) => {
                                    formik.setFieldValue("audioSystem", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Air Conditioner
                                </label>
                                <SwitcherOne meta={"airConditioner"} value={formik.values.airConditioner} onChange={(item) => {
                                    formik.setFieldValue("airConditioner", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Power Windows (Front)
                                </label>
                                <SwitcherOne meta={"powerWindowsFront"} value={formik.values.powerWindowsFront} onChange={(item) => {
                                    formik.setFieldValue("powerWindowsFront", item);
                                }} />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Power Outlet (12V)
                                </label>
                                <SwitcherOne meta={"powerOutlet12V"} value={formik.values.powerOutlet12V} onChange={(item) => {
                                    formik.setFieldValue("powerOutlet12V", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Steering Adjustment
                                </label>
                                <SwitcherOne meta={"steeringAdjustment"} value={formik.values.steeringAdjustment} onChange={(item) => {
                                    formik.setFieldValue("steeringAdjustment", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Push Button Start
                                </label>
                                <SwitcherOne meta={"pushButtonStart"} value={formik.values.pushButtonStart} onChange={(item) => {
                                    formik.setFieldValue("pushButtonStart", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Cruise Control
                                </label>
                                <SwitcherOne meta={"cruiseControl"} value={formik.values.cruiseControl} onChange={(item) => {
                                    formik.setFieldValue("cruiseControl", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Ventilated Seats (Front)
                                </label>
                                <SwitcherOne meta={"ventilatedSeatsFront"} value={formik.values.ventilatedSeatsFront} onChange={(item) => {
                                    formik.setFieldValue("ventilatedSeatsFront", item);
                                }} />
                            </div>
                        </div>

                        <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Rear AC
                                </label>
                                <SwitcherOne meta={"rearAC"} value={formik.values.rearAC} onChange={(item) => {
                                    formik.setFieldValue("rearAC", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Daytime Running Lights (DRL)
                                </label>
                                <SwitcherOne meta={"daytimeRunningLights"} value={formik.values.daytimeRunningLights} onChange={(item) => {
                                    formik.setFieldValue("daytimeRunningLights", item);
                                }} />
                            </div>

                            <div className="w-full xl:w-1/5">
                                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                                    Electrically Foldable Mirrors
                                </label>
                                <SwitcherOne meta={"electricallyFoldableMirrors"} value={formik.values.electricallyFoldableMirrors} onChange={(item) => {
                                    formik.setFieldValue("electricallyFoldableMirrors", item);
                                }} />
                            </div>

                        </div>

                        {
                            mutation.isPending || updateMutation.isPending ? <PageLoader /> : <button type="submit" className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
                                Submit
                            </button>
                        }
                    </div>
                </form>
            </div>
        </DefaultLayout>
    )
};
export default InventoryForm;