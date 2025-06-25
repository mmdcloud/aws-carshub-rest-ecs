import * as Yup from 'yup';

export const loginSchema = Yup.object().shape({
    contact:Yup.string().required("Contact should not be empty !").min(10,"Invalid contact !").max(10,"Invalid contact !"),
    password:Yup.string().required("Password should not be empty !").min(8,"Password should be atleast 8 characters long !")
});

export const userSchema = Yup.object().shape({
    fullname:Yup.string().required("Full name should not be empty !"),
    city: Yup.string().required("City should not be empty !"),
    dob:Yup.date("Invalid date !").required("DOB should not be empty !"),
    gender: Yup.string().required("Gender should not be empty !"),
    email:Yup.string().email("Invalid email !").required("Email should not be empty !"),
    contact:Yup.string().required("Contact should not be empty !").min(10,"Invalid contact !").max(10,"Invalid contact !"),
    password:Yup.string().min(8,"Password should be atleast 8 characters long !")
});

export const brandSchema = Yup.object().shape({
    name: Yup.string().required("Name should not be empty !"),
    countryOfOrigin: Yup.string().required("Country of origin should not be empty !")
});

export const reportSchema = Yup.object().shape({
    fromDate: Yup.string().required("From Date should not be empty !"),
    toDate: Yup.string().required("To Date of origin should not be empty !")
});

export const vehicleModelSchema = Yup.object().shape({
    name: Yup.string().required("Name should not be empty !"),
    brandId: Yup.string().required("Brand Id should not be empty !")
});

export const uploadFormSchema = Yup.object().shape({
    type: Yup.string().required("Type should not be empty !"),
    description: Yup.string().required("Description Id should not be empty !")
});

export const buyerSchema = Yup.object().shape({
    fullname:Yup.string().required("Full name should not be empty !"),
    city: Yup.string().required("City should not be empty !"),
    dob:Yup.date("Invalid date !").required("DOB should not be empty !"),
    gender: Yup.string().required("Gender should not be empty !"),
    email:Yup.string().email("Invalid email !").required("Email should not be empty !"),
    contact:Yup.string().required("Contact should not be empty !").min(10,"Invalid contact !").max(10,"Invalid contact !")    
});

export const vehicleOwnerSchema = Yup.object().shape({
    fullname:Yup.string().required("Full name should not be empty !"),
    city: Yup.string().required("City should not be empty !"),
    dob:Yup.date("Invalid date !").required("DOB should not be empty !"),
    gender: Yup.string().required("Gender should not be empty !"),
    email:Yup.string().email("Invalid email !").required("Email should not be empty !"),
    contact:Yup.string().required("Contact should not be empty !").min(10,"Invalid contact !").max(10,"Invalid contact !")    
});

export const orderSchema = Yup.object().shape({
    discount: Yup.string().required("Discount should not be empty !"),
    totalAmount: Yup.string().required("Total Amount should not be empty !"),
    buyerId: Yup.string().required("Buyer Id should not be empty !"),
    inventoryId: Yup.string().required("Inventory Id should not be empty !"),
    date: Yup.date("Invalid date !").required("Date should not be empty !")
});

export const extraServicesSchema = Yup.object().shape({
    discount: Yup.string().required("Discount should not be empty !"),
    title: Yup.string().required("Title should not be empty !"),
    price: Yup.string().required("Price should not be empty !"),
    orderId: Yup.string().required("Order Id should not be empty !"),
});

export const changePasswordSchema = Yup.object().shape({
    newPassword: Yup.string().required("New Password should not be empty !"),
    confirmPassword: Yup.string().required("Confirm Password should not be empty !")    
});