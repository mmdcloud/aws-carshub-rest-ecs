"use client";
import React from "react";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import ExtraServicesDetails from "@/components/ExtraServicesDetails/ExtraServicesCard";
import OrderDetailsCard from "@/components/OrderDetailsCard/OrderDetailsCard";
import {  useParams, useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import PageLoader from "@/components/common/Loader/pageLoader";
import axiosInstance from "@/network/axiosInstance";

const OrderDetails = () => {
    const router = useRouter();
    const params = useParams();
    const { data, isLoading, isError, error } = useQuery({
        queryKey: ["order-details"],
        queryFn: () => {
            return axiosInstance.get("/orders/getOrderDetailsWithExtraServices/"+ params.id);
        }
    })
    if(isError)
    {
        return <p>{error.message}</p>
    }
    return (
        <DefaultLayout>      
            {
                isLoading ? <PageLoader /> : <>
                    <div className="w-full flex justify-end">
                <button
                    onClick={() => {
                        router.push("/orders/"+params.id+"/other-services-form");
                    }}
                    className="flex justify-center rounded bg-primary px-6 py-2 font-medium text-gray hover:bg-opacity-90"
                    type="button"
                >
                    Add Servicing Charges
                </button>
            </div>  
            <div className="mt-4 grid grid-cols-12 gap-4 md:mt-6 md:gap-6 2xl:mt-7.5 2xl:gap-7.5">                
                <div className="col-span-12 xl:col-span-8">
                    <OrderDetailsCard data={data.data.orderData}/>
                </div>
                <ExtraServicesDetails data={data.data.extraServices}/>
            </div>
                </>
            }
        </DefaultLayout>
    );
};

export default OrderDetails;
