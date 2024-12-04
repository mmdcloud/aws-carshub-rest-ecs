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
                router.push("/users/form?" + params);
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
        key:"fullname"
    },
    {
        header:"City",
        key:"city"
    },
    {
        header:"Contact",
        key:"contact"
    },
    {
        header:"Actions",
        component: renderActions
    }
];

const Users = () => {     
    const router = useRouter();   
    const {data,error,isLoading,isError} = useQuery({      
        queryKey:["users"],
        queryFn:() => {
            return axiosInstance.get("/users");
        }
    })    
    return (
        <DefaultLayout>
            {
               isError ? <CustomAlert message={error.message} /> : isLoading ? <PageLoader/>: <TableTwo isActionVisible={true} actionOnClick={()=>{
                    router.push("/users/form");
                }} title={"Users"} tableDataKeys={tableDataKeys} data={data.data}/>
            }            
        </DefaultLayout>
    )
};
export default Users;