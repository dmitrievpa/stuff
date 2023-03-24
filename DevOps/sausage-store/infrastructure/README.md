Infrastructure project for backup sausage store
Student: Pavel Dmitriev
dvs 07 group 01
Terraform:
Before use this code create and fill terraform.tfvars
Example:
iam_token = "<Yandex cloud OAth token>"
vm_name = ["example-vm1", "example-vm2"<and etc.>]

Task 6-1
Database indexes:

   tablename   | indexname |                                indexdef
---------------+-----------+-------------------------------------------------------------------------
 order_product | idx_pr_id | CREATE INDEX idx_pr_id ON public.order_product USING btree (product_id)
 orders        | idx_o_id  | CREATE INDEX idx_o_id ON public.orders USING btree (id)
 product       | idx_id    | CREATE INDEX idx_id ON public.product USING btree (id)
(3 rows)
