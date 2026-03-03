import { Stack } from '@mui/system'
import RestaurantRegLandBanner from '@/components/restaurant-registration-landing/RestaurantRegLandBanner'
import RestaurantRegLandAbout from '@/components/restaurant-registration-landing/RestaurantRegLandAbout'
import RestaurantRegLandFeature from '@/components/restaurant-registration-landing/RestaurantRegLandFeature'
import RestaurantRegLandFaq from '@/components/restaurant-registration-landing/RestaurantRegLandFaq'


const RestaurantRegistrationLanding = ({data,configData}) => {
    const { hero_image_content_full_url, stepper, opportunities, faqs } = data
    const {business_name}=configData
    return (
        <Stack >
            <RestaurantRegLandBanner business_name={business_name} hero_image_content_full_url={hero_image_content_full_url} />
            <RestaurantRegLandAbout stepper={stepper}  />
            <RestaurantRegLandFeature configData={configData} opportunities={opportunities} business_name={business_name} />
            <RestaurantRegLandFaq faqs={faqs} />
        </Stack>
    )
}

export default RestaurantRegistrationLanding;
