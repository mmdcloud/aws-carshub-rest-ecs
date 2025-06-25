import { createSlice } from '@reduxjs/toolkit'

const initialState = {
  userData: {},
}

export const userSlice = createSlice({
  name: 'userData',
  initialState,
  reducers: {
    updateUserData: (state,action) => {
      state.userData = action.payload;
    },    
  },
})

export const { updateUserData } = userSlice.actions

export default userSlice.reducer