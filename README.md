[Visual Schema Link](https://lucid.app/lucidchart/582c392f-7113-4fb7-9a93-8697af8fa27d/edit?invitationId=inv_4ec19f91-a432-4b99-a0d2-09d50b682b5f&page=0_0#)


# Optimisation Notes
## Cost Calculation
- Split the individual stuff like registrations and options/adjustments out into separate methods that can be called on their own to minimise processing needed if only one reg is updated for examples
    - Or create mini versions used by callbacks on the relevant model
- Make everything you need (instance?) variables at the start of calc_cost 