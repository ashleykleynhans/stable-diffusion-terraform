#!/usr/bin/env python3
import os
import sys
import argparse
import boto3
import yaml
from datetime import datetime
from datetime import timedelta
from collections import namedtuple

SPOT_PRICE_LEEWAY_PERCENTAGE = 5
SPOT_TIME_PERIOD_DAYS = 90


def get_args():
    parser = argparse.ArgumentParser(
        description='Get EC2 spot price for a particular instance type in a particular region.',
    )

    parser.add_argument(
        '--region', '-region', '--r', '-r',
        type=str,
        required=True,
        help='AWS region (eg. us-east-1)'
    )

    parser.add_argument(
        '--instance-type', '-instance-type', '--i', '-i',
        type=str,
        required=True,
        help='EC2 Instance type (eg. t3a.large)'
    )

    return parser.parse_args()


def load_config(script_path):
    try:
        config_file = f'{script_path}/config.yml'

        with open(config_file, 'r') as stream:
            return yaml.safe_load(stream)
    except FileNotFoundError:
        print(f'ERROR: Config file {config_file} not found!')
        sys.exit()


def get_bid_price(region, instance_type):
    price_leeway_percentage = SPOT_PRICE_LEEWAY_PERCENTAGE
    instance_types = [instance_type]
    start = datetime.now() - timedelta(days=SPOT_TIME_PERIOD_DAYS)

    ec2 = boto3.client(
        'ec2',
        region_name=region,
        aws_access_key_id=config['aws_access_key_id'],
        aws_secret_access_key=config['aws_secret_access_key']
    )

    price_dict = ec2.describe_spot_price_history(
        StartTime=start,
        InstanceTypes=instance_types,
        ProductDescriptions=['Linux/UNIX']
    )

    price_list_item_count = len(price_dict.get('SpotPriceHistory'))

    if price_list_item_count > 0:
        PriceHistory = namedtuple('PriceHistory', 'price timestamp')
        price_list = []
        average_price = 0
        highest_price = 0
        lowest_price = 0

        for item in price_dict.get('SpotPriceHistory'):
            spot_price = round(float(item.get('SpotPrice')), 5)
            average_price += spot_price
            price_list.append(PriceHistory(spot_price, item.get('Timestamp')))

            if not highest_price:
                highest_price = spot_price
            else:
                if spot_price > highest_price:
                    highest_price = spot_price

            if not lowest_price:
                lowest_price = spot_price
            else:
                if spot_price < lowest_price:
                    lowest_price = spot_price

        average_price = round(float(average_price / price_list_item_count), 5)
        highest_price = round(float(highest_price), 5)
        lowest_price = round(float(lowest_price), 5)
        price_leeway = round(float(average_price / 100 * price_leeway_percentage), 5)
        bid_price = round(float(average_price + price_leeway), 5)

        if bid_price < highest_price:
            price_leeway = round(float(highest_price / 100 * price_leeway_percentage), 5)
            bid_price = round(float(highest_price + price_leeway), 5)

        return {
            'average_price': average_price,
            'highest_price': highest_price,
            'lowest_price': lowest_price,
            'price_leeway': price_leeway,
            'bid_price': bid_price
        }
    else:
        raise ValueError(f'Invalid instance type: {instance_type} provided. '
                         'Please provide correct instance type.')


if __name__ == '__main__':
    script_path = os.path.dirname(__file__)
    args = get_args()
    config = load_config(script_path)

    spot_price = get_bid_price(
        args.region,
        args.instance_type
    )

    print(spot_price['bid_price'])
