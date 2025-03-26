import axios from 'axios';

const axiosInstanceWithBlob = axios.create({
	// Configuration
	baseURL: process.env.BASE_URL,
	// baseURL:"http://localhost:3002",
	timeout: 10000,
	headers:{
		Accept:"multipart/form-data"
	}
});

export default axiosInstanceWithBlob;