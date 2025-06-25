"use client";
import { useQuery } from "@tanstack/react-query";
import axiosInstance from "../../network/axiosInstance";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import PageLoader from "../../components/common/Loader/pageLoader";
import TableTwo from "@/components/Tables/TableTwo";
import { useRouter } from "next/navigation";
import { Pencil } from "lucide-react";
import CustomAlert from "@/components/CustomAlert/Alert";

const renderActions = (item, key) => {
    const router = useRouter();
    return (
      <div key={key} className="flex items-center space-x-3.5">
          <button onClick={() => {
                var params = new URLSearchParams(item);
                router.push("/vehicle-models/form?" + params);
            }} className="hover:text-primary">
                <Pencil size={16} />
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
        header:"Name",
        key:"name"
    },
    {
        header:"Brand",
        key:"brand.name"
    },
    {
        header:"Actions",
        component: renderActions
    }
]

const VehicleModels = () => {        
    const router = useRouter();
    const {data,error,isLoading,isError} = useQuery({      
        queryKey:["vehicle-models"],
        queryFn:() => {
            return axiosInstance.get("/vehicle-models");
        }        
    })    
    return (
        <DefaultLayout>
            {
               isError ? <CustomAlert message={error.message} /> : isLoading ? <PageLoader/>: <TableTwo isActionVisible={true} actionOnClick={()=>{
                    router.push("/vehicle-models/form");
                }} title={"Vehicle Models"} tableDataKeys={tableDataKeys} data={data.data}/>
            }
        </DefaultLayout>
    )
};
export default VehicleModels;