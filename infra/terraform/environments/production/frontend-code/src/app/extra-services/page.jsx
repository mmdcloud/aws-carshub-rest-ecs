"use client";
import {  useQuery } from "@tanstack/react-query";
import axiosInstance from "../../network/axiosInstance";
import PageLoader from "../../components/common/Loader/pageLoader";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import TableTwo from "@/components/Tables/TableTwo";
import { useRouter } from "next/navigation";
import { Eye, X } from "lucide-react";
import CustomAlert from "@/components/CustomAlert/Alert";

const renderActions = (item, key) => {
    const router = useRouter();
    return (
        <div key={key} className="flex items-center space-x-3.5">
            <button onClick={() => {
                var params = new URLSearchParams(item);
                router.push("/orders/" + params.get("orderId"));
            }} className="hover:text-primary">
                <Eye size={16} />
            </button>           
            <button className="hover:text-primary">
                <X size={16}/>
            </button>
        </div>
    );
};

const tableDataKeys = [
    {
        header:"Id",
        key:"id"
    },
    {
        header:"Order Id",
        key:"orderId"
    },
    {
        header:"Title",
        key:"title"
    },
    {
        header:"Price",
        key:"price"
    },
    {
        header:"Actions",
        component:renderActions
    }
]

const ExtraServices = () => {
    const {data,error,isLoading,isError} = useQuery({      
        queryKey:["extra-services"],
        queryFn:() => {
            return axiosInstance.get("/extra-services");
        }
    })        
    return (
        <DefaultLayout>
            {
               isError ? <CustomAlert message={error.message} /> : isLoading ? <PageLoader/> : <TableTwo isActionVisible={false} title={"Extra Services"} tableDataKeys={tableDataKeys} data={data.data}/>
            }            
        </DefaultLayout>
    )
};
export default ExtraServices;